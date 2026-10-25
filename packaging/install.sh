#!/usr/bin/env bash
set -euo pipefail

# Install a Chroma build into ~/.local/share/chroma and put `chroma` on PATH.
#
# Usage:
#   packaging/install.sh [BUILD_OUTPUT_DIR]
#
# BUILD_OUTPUT_DIR is the folder that contains the native Chroma host and
# Application/ (for example src/Chroma/bin/Debug/net10.0). When omitted, the
# script looks for the newest net10.0 output under src/Chroma/bin/.

readonly APP_ID="org.omarchy.chroma"
readonly INSTALL_ROOT="${HOME}/.local/share/chroma"
readonly BIN_LINK="${HOME}/.local/bin/chroma"
readonly DESKTOP_DIR="${HOME}/.local/share/applications"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

resolve_build_dir() {
  if [[ $# -ge 1 && -n "${1:-}" ]]; then
    local candidate="$1"
    if [[ ! -d "$candidate" ]]; then
      echo "install.sh: build output directory not found: $candidate" >&2
      exit 1
    fi
    cd "$candidate" && pwd
    return
  fi

  local search_root="${repo_root}/src/Chroma/bin"
  if [[ ! -d "$search_root" ]]; then
    echo "install.sh: no build output under ${search_root}; build first or pass BUILD_OUTPUT_DIR" >&2
    exit 1
  fi

  local newest=""
  newest="$(
    find "$search_root" -type d -path '*/net10.0' -printf '%T@\t%p\n' 2>/dev/null \
      | sort -t "$(printf '\t')" -k1,1nr \
      | head -n1 \
      | cut -f2-
  )"

  if [[ -z "$newest" ]]; then
    echo "install.sh: no net10.0 output under ${search_root}; build first or pass BUILD_OUTPUT_DIR" >&2
    exit 1
  fi

  printf '%s\n' "$newest"
}

find_host_binary() {
  local build_dir="$1"
  if [[ -x "${build_dir}/Chroma" ]]; then
    echo "${build_dir}/Chroma"
    return
  fi
  if [[ -x "${build_dir}/chroma" ]]; then
    echo "${build_dir}/chroma"
    return
  fi
  echo "install.sh: no executable Chroma or chroma in ${build_dir}" >&2
  exit 1
}

build_dir="$(resolve_build_dir "${1:-}")"
host_binary="$(find_host_binary "$build_dir")"
host_name="$(basename "$host_binary")"

mkdir -p "$INSTALL_ROOT" "${HOME}/.local/bin" "$DESKTOP_DIR"

find "$INSTALL_ROOT" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
cp -a "${build_dir}/." "${INSTALL_ROOT}/"

installed_host="${INSTALL_ROOT}/${host_name}"
if [[ ! -x "$installed_host" ]]; then
  echo "install.sh: expected host at ${installed_host} after copy" >&2
  exit 1
fi

ln -sf "$installed_host" "$BIN_LINK"

desktop_src="${repo_root}/packaging/${APP_ID}.desktop"
desktop_dst="${DESKTOP_DIR}/${APP_ID}.desktop"
sed "s|^Exec=.*|Exec=${BIN_LINK}|" "$desktop_src" >"$desktop_dst"

if command -v desktop-file-validate >/dev/null 2>&1; then
  desktop-file-validate "$desktop_dst"
fi

echo "Installed Chroma to ${INSTALL_ROOT}"
echo "  chroma -> ${BIN_LINK} -> ${installed_host}"
echo "  desktop entry -> ${desktop_dst}"

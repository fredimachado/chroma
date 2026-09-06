# Chroma

Live Omarchy theme studio. Six pages: Studio, Palette, Surfaces, Type, Term, Session.

Chroma reads `omarchy-theme-color --all` and paints the window from that palette. Hyprland keeps the 2px SSD border. The client draws a matching 2px accent rule. The window is a headerless `Window`, not an `ApplicationWindow`.

## Build

You need .NET SDK 10 and Qt 6 at `/usr` (`/usr/lib/cmake/Qt6/Qt6Config.cmake`).

```bash
export QtDir=/usr
dotnet test tests/Chroma.Tests/Chroma.Tests.csproj
dotnet build src/Chroma/Chroma.csproj -p:QtDir=/usr
```

The Qt project skips `cmake --install` (Arch's `libfcitx5platforminputcontextplugin.so` has no ELF RPATH). It still copies QML into `Application/` next to the native host. Run that host from the output directory so it uses system `libQt6*.so` and can load `Application/Main.qml`.

```bash
src/Chroma/bin/Debug/net10.0/Chroma
```

## Theme-set hook

The hook pings `$XDG_RUNTIME_DIR/chroma.sock`. If `nc` cannot reach the socket, it writes `$XDG_RUNTIME_DIR/chroma.stamp`. Both paths call the same Reload. After a successful read, Chroma writes accent, background, and mode to `$XDG_RUNTIME_DIR/chroma.palette`.

```bash
omarchy hook install theme-set packaging/chroma-theme-set
```

You can also install the hook from the Session page.

## Desktop file

`packaging/org.omarchy.chroma.desktop` starts `Chroma`. Put the native host on `PATH`, or change `Exec` to the built path under `src/Chroma/bin/`.

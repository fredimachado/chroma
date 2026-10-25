using System.ComponentModel;
using Qt.MetaObject;
using Qt.Quick;

namespace Omarchy.Chroma;

internal readonly record struct SessionCapture(
    string ThemeName,
    string WallpaperPath,
    string IconTheme,
    string FontName,
    string QtDir,
    string ColorsTomlPath,
    bool HookInstalled,
    string CaptureError);

[QObject]
[QmlElement(Name = "App", Singleton = true)]
public sealed class App : INotifyPropertyChanged
{
    public enum Page
    {
        Studio,
        Palette,
        Surfaces,
        Type,
        Term,
        Controls,
        Wall,
        Keys,
        Notify,
        Editor,
        Session,
    }

    static readonly List<App> Live = [];
    static App? _instance;
    static Page _page = Page.Studio;
    static string _themeName = "";
    static string _wallpaperPath = "";
    static string _iconTheme = "";
    static string _fontName = "";
    static string _qtDir = "";
    static string _colorsTomlPath = "";
    static bool _hookInstalled;
    static string _lastError = "";

    public App()
    {
        // Same last-ctor rule as Palette: QML binds the second instance.
        _instance = this;
        Live.Add(this);
    }

    public static App Instance => _instance ??= new();

    public event PropertyChangedEventHandler? PropertyChanged;

    public Page page => _page;
    public string ThemeName => _themeName;
    public string WallpaperPath => _wallpaperPath;
    public string IconTheme => _iconTheme;
    public string FontName => _fontName;
    public string QtDir => _qtDir;
    public string ColorsTomlPath => _colorsTomlPath;
    public bool HookInstalled => _hookInstalled;
    public string LastError => _lastError;

    public void Go(Page page)
    {
        if (page == _page)
            return;
        _page = page;
        Raise(nameof(this.page));
    }

    public void RefreshSession()
        => ApplySession(CaptureSession());

    public static SessionCapture CaptureSession()
    {
        var home = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
        var current = Path.Combine(home, ".local", "state", "omarchy", "current");

        var (iconTheme, iconError) = ReadIconTheme();
        return new SessionCapture(
            ReadTrimmed(Path.Combine(current, "theme.name")),
            ResolveLink(Path.Combine(current, "background")),
            iconTheme,
            ReadFontName(),
            Environment.GetEnvironmentVariable("QtDir") is { Length: > 0 } qtDir ? qtDir : "/usr",
            Path.Combine(current, "theme", "colors.toml"),
            File.Exists(HookPath()),
            iconError);
    }

    public void ApplySession(SessionCapture session)
    {
        Assign(ref _themeName, session.ThemeName, nameof(ThemeName));
        Assign(ref _wallpaperPath, session.WallpaperPath, nameof(WallpaperPath));
        Assign(ref _iconTheme, session.IconTheme, nameof(IconTheme));
        Assign(ref _fontName, session.FontName, nameof(FontName));
        Assign(ref _qtDir, session.QtDir, nameof(QtDir));
        Assign(ref _colorsTomlPath, session.ColorsTomlPath, nameof(ColorsTomlPath));
        Assign(ref _hookInstalled, session.HookInstalled, nameof(HookInstalled));
        if (!string.IsNullOrEmpty(session.CaptureError))
            SetLastError(session.CaptureError);
    }

    public void InstallHook()
    {
        try
        {
            var path = HookPath();
            var dir = Path.GetDirectoryName(path);
            if (dir is not null)
                Directory.CreateDirectory(dir);

            File.WriteAllText(path, HookScript);
            if (OperatingSystem.IsLinux())
            {
                File.SetUnixFileMode(
                    path,
                    UnixFileMode.UserRead | UnixFileMode.UserWrite | UnixFileMode.UserExecute
                    | UnixFileMode.GroupRead | UnixFileMode.GroupExecute
                    | UnixFileMode.OtherRead | UnixFileMode.OtherExecute);
            }

            SetLastError("");
            Assign(ref _hookInstalled, true, nameof(HookInstalled));
        }
        catch (Exception ex)
        {
            SetLastError(ex.Message);
        }
    }

    internal void SetLastError(string error)
        => Assign(ref _lastError, error ?? "", nameof(LastError));

    static string HookPath()
    {
        var home = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
        return Path.Combine(home, ".config", "omarchy", "hooks", "theme-set.d", "chroma-theme-set");
    }

    const string HookScript = """
        #!/bin/bash
        sock="${XDG_RUNTIME_DIR:-/tmp}/chroma.sock"
        stamp="${XDG_RUNTIME_DIR:-/tmp}/chroma.stamp"
        if printf x | nc -U -N "$sock" >/dev/null 2>&1; then
          exit 0
        fi
        : > "$stamp"

        """;

    static string ReadTrimmed(string path)
    {
        try
        {
            return File.Exists(path) ? File.ReadAllText(path).Trim() : "";
        }
        catch
        {
            return "";
        }
    }

    static string ResolveLink(string path)
    {
        try
        {
            var resolved = File.ResolveLinkTarget(path, returnFinalTarget: true);
            if (resolved is not null)
                return resolved.FullName;
            return File.Exists(path) ? Path.GetFullPath(path) : "";
        }
        catch
        {
            return "";
        }
    }

    static readonly TimeSpan SessionProcessTimeout = TimeSpan.FromMilliseconds(1500);

    static (string Theme, string Error) ReadIconTheme()
    {
        var result = ProcessRunner.Run(
            "gsettings",
            ["get", "org.gnome.desktop.interface", "icon-theme"],
            timeout: SessionProcessTimeout);
        if (!result.Ok)
            return ("", FormatProcessError("gsettings", result));

        var theme = result.StdOut.Trim().Trim('\'', '"');
        return (theme, "");
    }

    static string ReadFontName()
    {
        var current = ProcessRunner.Run("omarchy-font-current", [], timeout: SessionProcessTimeout);
        if (current.Ok && current.StdOut.Trim().Length > 0)
            return current.StdOut.Trim();

        var match = ProcessRunner.Run(
            "fc-match",
            ["monospace", "-f", "%{family}\n"],
            timeout: SessionProcessTimeout);
        if (match.Ok && match.StdOut.Trim().Length > 0)
            return match.StdOut.Trim();

        return "monospace";
    }

    static string FormatProcessError(string name, ProcessRunResult result)
    {
        if (result.TimedOut)
            return $"{name} timed out.";
        return string.IsNullOrWhiteSpace(result.StdErr)
            ? $"{name} exited {result.ExitCode}."
            : result.StdErr.Trim();
    }

    void Assign(ref string field, string value, string name)
    {
        if (field == value)
            return;
        field = value;
        Raise(name);
    }

    void Assign(ref bool field, bool value, string name)
    {
        if (field == value)
            return;
        field = value;
        Raise(name);
    }

    void Raise(string name)
    {
        foreach (var live in Live)
            live.PropertyChanged?.Invoke(live, new PropertyChangedEventArgs(name));
    }
}

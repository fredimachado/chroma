using System.ComponentModel;
using System.Diagnostics;
using Qt.MetaObject;
using Qt.Quick;

namespace Omarchy.Chroma;

[QObject]
public sealed class Swatch : INotifyPropertyChanged
{
    public Swatch(string key)
    {
        Key = key;
        Hex = HexColor.Fallback.Value;
        Luminance = HexColor.Fallback.Luminance;
    }

    public event PropertyChangedEventHandler? PropertyChanged;

    public string Key { get; }
    public string Hex { get; private set; }
    public double Luminance { get; private set; }

    public void Copy()
    {
        try
        {
            var psi = new ProcessStartInfo
            {
                FileName = "wl-copy",
                RedirectStandardInput = true,
                UseShellExecute = false,
            };
            using var process = Process.Start(psi);
            if (process is null)
                return;
            process.StandardInput.Write(Hex);
            process.StandardInput.Close();
            process.WaitForExit(500);
        }
        catch
        {
        }
    }

    internal bool TryAssign(HexColor color)
    {
        if (Hex == color.Value && Luminance == color.Luminance)
            return false;

        Hex = color.Value;
        Luminance = color.Luminance;
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(nameof(Hex)));
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(nameof(Luminance)));
        return true;
    }
}

[QObject]
[QmlElement(Name = "Theme", Singleton = true)]
public sealed class Palette : INotifyPropertyChanged
{
    static readonly SemanticColor[] Keys = Enum.GetValues<SemanticColor>();
    static readonly Swatch[] Store = CreateStore();
    static readonly List<Palette> Live = [];
    static readonly object ReloadGate = new();

    static Palette? _instance;
    static string _mode = "dark";
    static string _lastReloaded = "";
    static bool _reloadRunning;
    static bool _reloadQueued;

    public Palette()
    {
        // QML_SINGLETON constructs a second object after Program.Instance.Reload.
        // Last ctor wins so later Reloads notify the bound instance. The swatch store is static.
        _instance = this;
        Live.Add(this);
    }

    public static Palette Instance => _instance ??= new();

    public event PropertyChangedEventHandler? PropertyChanged;

    public Swatch[] Tokens => Store;

    public string Mode => _mode;
    public string LastReloaded => _lastReloaded;

    public string Accent => Slot(SemanticColor.Accent);
    public string Selection => Slot(SemanticColor.Selection);
    public string Muted => Slot(SemanticColor.Muted);
    public string Background => Slot(SemanticColor.Background);
    public string DarkBackground => Slot(SemanticColor.DarkBackground);
    public string DarkerBackground => Slot(SemanticColor.DarkerBackground);
    public string LighterBackground => Slot(SemanticColor.LighterBackground);
    public string Foreground => Slot(SemanticColor.Foreground);
    public string DarkForeground => Slot(SemanticColor.DarkForeground);
    public string LightForeground => Slot(SemanticColor.LightForeground);
    public string BrightForeground => Slot(SemanticColor.BrightForeground);
    public string Red => Slot(SemanticColor.Red);
    public string Yellow => Slot(SemanticColor.Yellow);
    public string Orange => Slot(SemanticColor.Orange);
    public string Green => Slot(SemanticColor.Green);
    public string Cyan => Slot(SemanticColor.Cyan);
    public string Blue => Slot(SemanticColor.Blue);
    public string Magenta => Slot(SemanticColor.Magenta);
    public string Brown => Slot(SemanticColor.Brown);
    public string BrightRed => Slot(SemanticColor.BrightRed);
    public string BrightYellow => Slot(SemanticColor.BrightYellow);
    public string BrightGreen => Slot(SemanticColor.BrightGreen);
    public string BrightCyan => Slot(SemanticColor.BrightCyan);
    public string BrightBlue => Slot(SemanticColor.BrightBlue);
    public string BrightMagenta => Slot(SemanticColor.BrightMagenta);

    public bool Reload()
    {
        lock (ReloadGate)
        {
            if (_reloadRunning)
            {
                _reloadQueued = true;
                return false;
            }

            _reloadRunning = true;
        }

        var changed = false;
        try
        {
            while (true)
            {
                if (ThemeColor.TryReadAll(out var snap, out var error))
                {
                    App.Instance.SetLastError("");
                    WriteRuntimePalette(snap);
                    if (Apply(snap))
                        changed = true;
                }
                else
                {
                    App.Instance.SetLastError(error);
                }

                lock (ReloadGate)
                {
                    if (!_reloadQueued)
                    {
                        _reloadRunning = false;
                        return changed;
                    }

                    _reloadQueued = false;
                }
            }
        }
        catch
        {
            lock (ReloadGate)
                _reloadRunning = false;
            throw;
        }
    }

    static Swatch[] CreateStore()
    {
        var tokens = new Swatch[Keys.Length];
        foreach (var key in Keys)
            tokens[(int)key] = new Swatch(ThemeColor.ToWire(key));
        return tokens;
    }

    static string Slot(SemanticColor key) => Store[(int)key].Hex;

    static void WriteRuntimePalette(ThemeSnapshot snap)
    {
        try
        {
            var dir = Environment.GetEnvironmentVariable("XDG_RUNTIME_DIR");
            if (string.IsNullOrEmpty(dir))
                return;
            var mode = snap.Mode == ThemeMode.Light ? "light" : "dark";
            File.WriteAllText(
                Path.Combine(dir, "chroma.palette"),
                $"{snap[SemanticColor.Accent].Value}\n{snap[SemanticColor.Background].Value}\n{mode}\n");
        }
        catch
        {
        }
    }

    bool Apply(ThemeSnapshot snap)
    {
        var changed = false;
        foreach (var key in Keys)
        {
            if (!Store[(int)key].TryAssign(snap[key]))
                continue;
            changed = true;
            Raise(PropertyName(key));
        }

        var mode = snap.Mode == ThemeMode.Light ? "light" : "dark";
        if (mode != _mode)
        {
            _mode = mode;
            changed = true;
            Raise(nameof(Mode));
        }

        if (!changed)
            return false;

        _lastReloaded = snap.ReadAt.ToLocalTime().ToString("O");
        Raise(nameof(LastReloaded));
        return true;
    }

    void Raise(string name)
    {
        foreach (var live in Live)
            live.PropertyChanged?.Invoke(live, new PropertyChangedEventArgs(name));
    }

    static string PropertyName(SemanticColor key) => key.ToString();
}

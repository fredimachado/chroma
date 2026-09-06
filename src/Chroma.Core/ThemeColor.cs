using System.Diagnostics;
using System.Text;

namespace Omarchy.Chroma;

public static class ThemeColor
{
    static readonly SemanticColor[] Keys = Enum.GetValues<SemanticColor>();

    static readonly Dictionary<string, SemanticColor> Aliases = new(StringComparer.Ordinal)
    {
        ["bg"] = SemanticColor.Background,
        ["dark_bg"] = SemanticColor.DarkBackground,
        ["darker_bg"] = SemanticColor.DarkerBackground,
        ["lighter_bg"] = SemanticColor.LighterBackground,
        ["fg"] = SemanticColor.Foreground,
        ["dark_fg"] = SemanticColor.DarkForeground,
        ["light_fg"] = SemanticColor.LightForeground,
        ["bright_fg"] = SemanticColor.BrightForeground,
        ["purple"] = SemanticColor.Magenta,
        ["bright_purple"] = SemanticColor.BrightMagenta,
        ["selection_background"] = SemanticColor.Selection,
    };

    public static bool TryReadAll(out ThemeSnapshot snapshot, out string error)
    {
        snapshot = default;
        error = "";

        try
        {
            var psi = new ProcessStartInfo
            {
                FileName = ResolveCli(),
                Arguments = "--all",
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
            };

            using var process = Process.Start(psi);
            if (process is null)
            {
                error = "omarchy-theme-color did not start.";
                return false;
            }

            var stdout = process.StandardOutput.ReadToEnd();
            process.WaitForExit();
            if (process.ExitCode != 0 || string.IsNullOrWhiteSpace(stdout))
            {
                var stderr = process.StandardError.ReadToEnd();
                error = string.IsNullOrWhiteSpace(stderr)
                    ? $"omarchy-theme-color exited {process.ExitCode}."
                    : stderr.Trim();
                return false;
            }

            snapshot = Parse(stdout);
            return true;
        }
        catch (Exception ex)
        {
            error = ex.Message;
            return false;
        }
    }

    public static ThemeSnapshot Parse(string stdout)
    {
        var table = new Dictionary<string, string>(StringComparer.Ordinal);
        foreach (var rawLine in stdout.Split(['\r', '\n'], StringSplitOptions.RemoveEmptyEntries))
        {
            var tab = rawLine.IndexOf('\t');
            if (tab <= 0)
                continue;

            var key = rawLine[..tab].Trim();
            var value = rawLine[(tab + 1)..].Trim();
            if (key.Length == 0)
                continue;

            table[key] = value;
        }

        var mode = ThemeMode.Dark;
        if (table.TryGetValue("mode", out var modeWord) && TryParseMode(modeWord, out var parsedMode))
            mode = parsedMode;
        else if (table.TryGetValue("theme_type", out var typeWord) && TryParseMode(typeWord, out parsedMode))
            mode = parsedMode;

        var colors = new HexColor[Keys.Length];
        var assigned = new bool[Keys.Length];
        Array.Fill(colors, HexColor.Fallback);

        foreach (var key in Keys)
        {
            var wire = ToWire(key);
            if (!table.TryGetValue(wire, out var hex) || !HexColor.TryParse(hex, out var color))
                continue;
            colors[(int)key] = color;
            assigned[(int)key] = true;
        }

        foreach (var (alias, target) in Aliases)
        {
            var index = (int)target;
            if (assigned[index])
                continue;
            if (!table.TryGetValue(alias, out var hex) || !HexColor.TryParse(hex, out var color))
                continue;
            colors[index] = color;
            assigned[index] = true;
        }

        return new ThemeSnapshot(mode, colors, DateTimeOffset.UtcNow);
    }

    public static string ToWire(SemanticColor key)
    {
        var name = key.ToString();
        var text = new StringBuilder(name.Length + 4);
        foreach (var ch in name)
        {
            if (char.IsUpper(ch) && text.Length > 0)
                text.Append('_');
            text.Append(char.ToLowerInvariant(ch));
        }

        return text.ToString();
    }

    static bool TryParseMode(string word, out ThemeMode mode)
    {
        if (word.Equals("light", StringComparison.OrdinalIgnoreCase))
        {
            mode = ThemeMode.Light;
            return true;
        }

        if (word.Equals("dark", StringComparison.OrdinalIgnoreCase))
        {
            mode = ThemeMode.Dark;
            return true;
        }

        mode = ThemeMode.Dark;
        return false;
    }

    static string ResolveCli()
    {
        const string name = "omarchy-theme-color";
        const string omarchyPath = "/usr/share/omarchy/bin/omarchy-theme-color";
        return File.Exists(omarchyPath) ? omarchyPath : name;
    }
}

namespace Omarchy.Chroma;

static class ThemeDefaults
{
    static readonly IReadOnlyDictionary<SemanticColor, string> Palette = new Dictionary<SemanticColor, string>
    {
        [SemanticColor.Accent] = "#7aa2f7",
        [SemanticColor.Selection] = "#292e42",
        [SemanticColor.Muted] = "#414868",
        [SemanticColor.Background] = "#1a1b26",
        [SemanticColor.DarkBackground] = "#13141c",
        [SemanticColor.DarkerBackground] = "#0e0e14",
        [SemanticColor.LighterBackground] = "#24283b",
        [SemanticColor.Foreground] = "#a9b1d6",
        [SemanticColor.DarkForeground] = "#565f89",
        [SemanticColor.LightForeground] = "#b4bee6",
        [SemanticColor.BrightForeground] = "#c0caf5",
        [SemanticColor.Red] = "#f7768e",
        [SemanticColor.Yellow] = "#e0af68",
        [SemanticColor.Orange] = "#eb927b",
        [SemanticColor.Green] = "#9ece6a",
        [SemanticColor.Cyan] = "#449dab",
        [SemanticColor.Blue] = "#7aa2f7",
        [SemanticColor.Magenta] = "#ad8ee6",
        [SemanticColor.Brown] = "#75493d",
        [SemanticColor.BrightRed] = "#ff7a93",
        [SemanticColor.BrightYellow] = "#ff9e64",
        [SemanticColor.BrightGreen] = "#b9f27c",
        [SemanticColor.BrightCyan] = "#0db9d7",
        [SemanticColor.BrightBlue] = "#7da6ff",
        [SemanticColor.BrightMagenta] = "#bb9af7",
    };

    internal static ThemeSnapshot CreateSnapshot()
    {
        var keys = Enum.GetValues<SemanticColor>();
        var colors = new HexColor[keys.Length];
        for (var i = 0; i < keys.Length; i++)
            colors[i] = HexColor.Parse(Palette[keys[i]]);

        return new ThemeSnapshot(ThemeMode.Dark, colors, DateTimeOffset.UtcNow);
    }
}

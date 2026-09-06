namespace Omarchy.Chroma;

public readonly struct ThemeSnapshot
{
    readonly HexColor[] _colors;

    internal ThemeSnapshot(ThemeMode mode, HexColor[] colors, DateTimeOffset readAt)
    {
        var expected = Enum.GetValues<SemanticColor>().Length;
        if (colors.Length != expected)
            throw new ArgumentException($"ThemeSnapshot requires {expected} colors.", nameof(colors));

        Mode = mode;
        ReadAt = readAt;
        _colors = [.. colors];
    }

    public ThemeMode Mode { get; }
    public DateTimeOffset ReadAt { get; }

    public HexColor this[SemanticColor key] => _colors[(int)key];
}

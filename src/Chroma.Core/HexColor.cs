using System.Globalization;

namespace Omarchy.Chroma;

public readonly record struct HexColor
{
    public string Value { get; }
    public double Luminance { get; }

    HexColor(string value, double luminance)
    {
        Value = value;
        Luminance = luminance;
    }

    public static HexColor Fallback { get; } = new("#000000", 0);

    public static HexColor Parse(string raw)
    {
        if (!TryParse(raw, out var color))
            throw new FormatException($"Invalid hex color '{raw}'.");
        return color;
    }

    public static bool TryParse(string raw, out HexColor color)
    {
        color = default;
        if (raw is not { Length: 7 } || raw[0] != '#')
            return false;

        if (!byte.TryParse(raw.AsSpan(1, 2), NumberStyles.HexNumber, CultureInfo.InvariantCulture, out var r)
            || !byte.TryParse(raw.AsSpan(3, 2), NumberStyles.HexNumber, CultureInfo.InvariantCulture, out var g)
            || !byte.TryParse(raw.AsSpan(5, 2), NumberStyles.HexNumber, CultureInfo.InvariantCulture, out var b))
            return false;

        color = new($"#{r:x2}{g:x2}{b:x2}", RelativeLuminance(r, g, b));
        return true;
    }

    static double RelativeLuminance(byte r, byte g, byte b)
        => (0.2126 * Linear(r)) + (0.7152 * Linear(g)) + (0.0722 * Linear(b));

    static double Linear(byte channel)
    {
        var srgb = channel / 255.0;
        return srgb <= 0.04045
            ? srgb / 12.92
            : Math.Pow((srgb + 0.055) / 1.055, 2.4);
    }
}

using Xunit;

namespace Omarchy.Chroma.Tests;

public sealed class ThemeColorTests
{
    static string Fixture => File.ReadAllText(
        Path.Combine(AppContext.BaseDirectory, "Fixtures", "tokyo-night-all.tsv"));

    [Fact]
    public void Parse_maps_tokyo_night_accent_background_and_mode()
    {
        var snap = ThemeColor.Parse(Fixture);

        Assert.Equal("#7aa2f7", snap[SemanticColor.Accent].Value);
        Assert.Equal("#1a1b26", snap[SemanticColor.Background].Value);
        Assert.Equal(ThemeMode.Dark, snap.Mode);
    }

    [Fact]
    public void Parse_does_not_keep_bg_as_a_token_key()
    {
        var snap = ThemeColor.Parse(Fixture);
        var keys = Enum.GetValues<SemanticColor>().Select(ThemeColor.ToWire).ToArray();

        Assert.DoesNotContain("bg", keys);
        Assert.Equal("#1a1b26", snap[SemanticColor.Background].Value);
    }

    [Fact]
    public void Parse_drops_color0()
    {
        const string tsv = """
            color0	#1a1b26
            accent	#7aa2f7
            mode	dark
            """;

        var snap = ThemeColor.Parse(tsv);
        var keys = Enum.GetValues<SemanticColor>().Select(ThemeColor.ToWire).ToArray();

        Assert.DoesNotContain("color0", keys);
        Assert.Equal("#7aa2f7", snap[SemanticColor.Accent].Value);
        Assert.Equal(HexColor.Fallback.Value, snap[SemanticColor.Background].Value);
    }

    [Fact]
    public void Parse_skips_invalid_hex_without_throwing_half_state()
    {
        const string tsv = """
            accent	#7aa2f7
            background	not-a-color
            mode	dark
            """;

        var snap = ThemeColor.Parse(tsv);

        Assert.Equal("#7aa2f7", snap[SemanticColor.Accent].Value);
        Assert.Equal(HexColor.Fallback.Value, snap[SemanticColor.Background].Value);
        Assert.Equal(ThemeMode.Dark, snap.Mode);
        Assert.Equal(0, snap[SemanticColor.Background].Luminance);
    }

    [Fact]
    public void Luminance_of_black_is_zero_and_white_is_one()
    {
        Assert.Equal(0, HexColor.Parse("#000000").Luminance);
        Assert.Equal(1, HexColor.Parse("#ffffff").Luminance);
        Assert.Equal(0, HexColor.Fallback.Luminance);
    }
}

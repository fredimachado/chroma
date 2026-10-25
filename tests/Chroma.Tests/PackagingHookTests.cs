using Xunit;

namespace Omarchy.Chroma.Tests;

public sealed class PackagingHookTests
{
    [Fact]
    public void ThemeSetHookScript_ExistsInPackaging()
    {
        var repoRoot = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", ".."));
        var hookPath = Path.Combine(repoRoot, "packaging", "chroma-theme-set");
        Assert.True(File.Exists(hookPath), $"Expected hook script at {hookPath}");

        var text = File.ReadAllText(hookPath);
        Assert.Contains("chroma.sock", text);
        Assert.Contains("chroma.stamp", text);
    }
}

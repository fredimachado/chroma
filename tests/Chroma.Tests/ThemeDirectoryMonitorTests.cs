using Xunit;

namespace Omarchy.Chroma.Tests;

public sealed class ThemeDirectoryMonitorTests
{
    [Fact]
    public void Replacing_theme_directory_signals_within_debounce_window()
    {
        var root = Path.Combine(Path.GetTempPath(), "chroma-monitor-" + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(root);
        var themeDir = Path.Combine(root, "theme");
        Directory.CreateDirectory(themeDir);
        File.WriteAllText(Path.Combine(root, "theme.name"), "seed");

        var signals = 0;
        using var monitor = new ThemeDirectoryMonitor(root);
        monitor.Changed += () => Interlocked.Increment(ref signals);
        monitor.Start();

        Directory.Delete(themeDir, true);
        Directory.CreateDirectory(themeDir);
        File.WriteAllText(Path.Combine(root, "theme.name"), "tokyo-night");

        var signaled = SpinWait.SpinUntil(() => Volatile.Read(ref signals) > 0, TimeSpan.FromMilliseconds(500));
        Assert.True(signaled, "Expected a debounced change signal after theme directory replacement.");

        try
        {
            Directory.Delete(root, true);
        }
        catch
        {
        }
    }
}

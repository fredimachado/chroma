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

        // Give FileSystemWatcher time to arm before the first mutation (slow CI hosts).
        Thread.Sleep(100);

        Directory.Delete(themeDir, true);
        Directory.CreateDirectory(themeDir);
        File.WriteAllText(Path.Combine(root, "theme.name"), "tokyo-night");

        var signaled = SpinWait.SpinUntil(() => Volatile.Read(ref signals) > 0, TimeSpan.FromSeconds(3));
        Assert.True(signaled, "Expected a debounced change signal after theme directory replacement.");

        try
        {
            Directory.Delete(root, true);
        }
        catch
        {
        }
    }

    [Fact]
    public void Start_before_root_exists_still_observes_changes_after_directory_appears()
    {
        var root = Path.Combine(Path.GetTempPath(), "chroma-monitor-" + Guid.NewGuid().ToString("N"));
        var signals = 0;
        using var monitor = new ThemeDirectoryMonitor(root);
        monitor.Changed += () => Interlocked.Increment(ref signals);
        monitor.Start();

        Directory.CreateDirectory(root);
        Thread.Sleep(300);
        File.WriteAllText(Path.Combine(root, "theme.name"), "seed");

        var signaled = SpinWait.SpinUntil(() => Volatile.Read(ref signals) > 0, TimeSpan.FromSeconds(3));
        Assert.True(signaled, "Expected a change signal after the theme root directory was created.");

        try
        {
            Directory.Delete(root, true);
        }
        catch
        {
        }
    }

    [Fact]
    public void Deleting_theme_root_then_recreating_still_signals_after_retry()
    {
        var root = Path.Combine(Path.GetTempPath(), "chroma-monitor-" + Guid.NewGuid().ToString("N"));
        Directory.CreateDirectory(root);
        File.WriteAllText(Path.Combine(root, "theme.name"), "seed");

        var signals = 0;
        using var monitor = new ThemeDirectoryMonitor(root);
        monitor.Changed += () => Interlocked.Increment(ref signals);
        monitor.Start();

        Directory.Delete(root, true);
        Directory.CreateDirectory(root);
        File.WriteAllText(Path.Combine(root, "theme.name"), "after-retry");

        var signaled = SpinWait.SpinUntil(() => Volatile.Read(ref signals) > 0, TimeSpan.FromSeconds(5));
        Assert.True(signaled, "Expected a change signal after the theme root was deleted and recreated.");

        try
        {
            Directory.Delete(root, true);
        }
        catch
        {
        }
    }
}

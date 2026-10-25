using System.Diagnostics;
using Xunit;

namespace Omarchy.Chroma.Tests;

public sealed class ProcessRunnerTests
{
    /// <summary>
    /// Uses the SleepHost test helper (dotnet exec) so the child PID can be verified after timeout kill.
    /// </summary>
    [Fact]
    public void Run_times_out_and_kills_long_running_child()
    {
        var hostDll = Path.Combine(AppContext.BaseDirectory, "SleepHost.dll");
        Assert.True(File.Exists(hostDll), $"Missing test helper at {hostDll}");

        var pidFile = Path.Combine(Path.GetTempPath(), "chroma-sleep-" + Guid.NewGuid().ToString("N") + ".pid");
        try
        {
            var result = ProcessRunner.Run(
                ResolveDotNetHost(),
                [hostDll, pidFile, "600"],
                timeout: TimeSpan.FromMilliseconds(400));

            Assert.False(result.Ok);
            Assert.True(result.TimedOut);

            Assert.True(File.Exists(pidFile), "SleepHost should write its PID before sleeping.");
            var pid = int.Parse(File.ReadAllText(pidFile).Trim());

            Assert.True(IsProcessGone(pid), $"Expected process {pid} to be terminated after timeout.");
        }
        finally
        {
            if (File.Exists(pidFile))
                File.Delete(pidFile);
        }
    }

    static string ResolveDotNetHost()
    {
        var processPath = Environment.ProcessPath;
        if (processPath is not null
            && Path.GetFileNameWithoutExtension(processPath).Equals("dotnet", StringComparison.OrdinalIgnoreCase))
            return processPath;

        return "dotnet";
    }

    static bool IsProcessGone(int pid)
    {
        try
        {
            using var process = Process.GetProcessById(pid);
            return process.HasExited;
        }
        catch (ArgumentException)
        {
            return true;
        }
    }
}

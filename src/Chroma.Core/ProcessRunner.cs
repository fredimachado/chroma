using System.ComponentModel;
using System.Diagnostics;
using System.Text;

namespace Omarchy.Chroma;

public readonly record struct ProcessRunResult(bool Ok, string StdOut, string StdErr, int ExitCode, bool TimedOut = false);

public static class ProcessRunner
{
    public static TimeSpan DefaultTimeout => TimeSpan.FromSeconds(30);
    static readonly TimeSpan PostKillWait = TimeSpan.FromSeconds(5);

    public static ProcessRunResult Run(
        string fileName,
        IReadOnlyList<string>? arguments = null,
        string? stdin = null,
        TimeSpan? timeout = null)
    {
        timeout ??= DefaultTimeout;

        try
        {
            var psi = new ProcessStartInfo
            {
                FileName = fileName,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                RedirectStandardInput = stdin is not null,
                UseShellExecute = false,
                StandardOutputEncoding = Encoding.UTF8,
                StandardErrorEncoding = Encoding.UTF8,
            };

            if (arguments is not null)
            {
                foreach (var argument in arguments)
                    psi.ArgumentList.Add(argument);
            }

            using var process = Process.Start(psi);
            if (process is null)
                return new ProcessRunResult(false, "", "Process did not start.", -1);

            var stdoutTask = process.StandardOutput.ReadToEndAsync();
            var stderrTask = process.StandardError.ReadToEndAsync();

            if (stdin is not null)
            {
                process.StandardInput.Write(stdin);
                process.StandardInput.Close();
            }

            var timedOut = false;
            if (!process.WaitForExit((int)timeout.Value.TotalMilliseconds))
            {
                timedOut = true;
                TryKillTree(process);
                process.WaitForExit((int)PostKillWait.TotalMilliseconds);
            }

            Task.WaitAll(stdoutTask, stderrTask);

            var exitCode = timedOut ? -1 : process.ExitCode;
            var stdout = stdoutTask.Result;
            var stderr = stderrTask.Result;
            var ok = !timedOut && exitCode == 0;

            return new ProcessRunResult(ok, stdout, stderr, exitCode, timedOut);
        }
        catch (Exception ex)
        {
            return new ProcessRunResult(false, "", ex.Message, -1);
        }
    }

    static void TryKillTree(Process process)
    {
        try
        {
            process.Kill(entireProcessTree: true);
        }
        catch (InvalidOperationException)
        {
        }
        catch (Win32Exception)
        {
        }
        catch (NotSupportedException)
        {
            try
            {
                process.Kill();
            }
            catch (InvalidOperationException)
            {
            }
            catch (Win32Exception)
            {
            }
        }
    }
}

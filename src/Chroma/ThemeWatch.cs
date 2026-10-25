using System.Net.Sockets;
using Qt.MetaObject;

namespace Omarchy.Chroma;

[Qt.Ignore]
public static class ThemeWatch
{
    const int DebounceMilliseconds = 80;

    static readonly object Gate = new();
    static Action? _onThemeSignal;
    static SynchronizationContext? _ui;
    static ThemeDirectoryMonitor? _directoryMonitor;
    static FileSystemWatcher? _stampWatcher;
    static Socket? _listener;
    static CancellationTokenSource? _debounce;
    static CancellationTokenSource? _listenCancel;
    static bool _started;

    public static void Start(Action onThemeSignal)
    {
        if (_started)
            return;

        _onThemeSignal = onThemeSignal;
        _ui = SynchronizationContext.Current;
        _started = true;

        // Directory monitor debounces FS events internally; stamp/socket share this gate (~160ms total is fine).
        _directoryMonitor = new ThemeDirectoryMonitor();
        _directoryMonitor.Changed += Signal;
        _directoryMonitor.Start();

        ListenSocket();
        WatchStamp();
    }

    public static void Stop()
    {
        _started = false;
        _listenCancel?.Cancel();
        _listenCancel?.Dispose();
        _listenCancel = null;
        _debounce?.Cancel();
        _debounce?.Dispose();
        _debounce = null;
        _directoryMonitor?.Dispose();
        _directoryMonitor = null;
        _stampWatcher?.Dispose();
        _stampWatcher = null;
        _listener?.Dispose();
        _listener = null;

        var sockPath = Path.Combine(RuntimeDir(), "chroma.sock");
        try
        {
            if (File.Exists(sockPath))
                File.Delete(sockPath);
        }
        catch
        {
        }
    }

    static void WatchStamp()
    {
        var dir = RuntimeDir();
        Directory.CreateDirectory(dir);
        var watcher = new FileSystemWatcher(dir, "chroma.stamp")
        {
            NotifyFilter = NotifyFilters.FileName | NotifyFilters.LastWrite,
            EnableRaisingEvents = true,
        };
        watcher.Created += (_, _) => Signal();
        watcher.Changed += (_, _) => Signal();
        _stampWatcher = watcher;
    }

    static void ListenSocket()
    {
        var path = Path.Combine(RuntimeDir(), "chroma.sock");
        try
        {
            if (File.Exists(path))
                File.Delete(path);

            var listener = new Socket(AddressFamily.Unix, SocketType.Stream, ProtocolType.Unspecified);
            listener.Bind(new UnixDomainSocketEndPoint(path));
            listener.Listen(8);
            _listener = listener;
            _listenCancel = new CancellationTokenSource();
            _ = Task.Run(() => AcceptLoop(listener, _listenCancel.Token));
        }
        catch (Exception ex)
        {
            App.Instance.SetLastError(ex.Message);
        }
    }

    static async Task AcceptLoop(Socket listener, CancellationToken token)
    {
        while (!token.IsCancellationRequested)
        {
            try
            {
                var client = await listener.AcceptAsync(token);
                _ = Drain(client, token);
                Signal();
            }
            catch (OperationCanceledException)
            {
                return;
            }
            catch
            {
                if (token.IsCancellationRequested)
                    return;
                await Task.Delay(DebounceMilliseconds, token);
            }
        }
    }

    static async Task Drain(Socket client, CancellationToken token)
    {
        try
        {
            var buffer = new byte[16];
            while (await client.ReceiveAsync(buffer, SocketFlags.None, token) > 0)
            {
            }
        }
        catch
        {
        }
        finally
        {
            client.Dispose();
        }
    }

    static void Signal()
    {
        lock (Gate)
        {
            _debounce?.Cancel();
            _debounce?.Dispose();
            _debounce = new CancellationTokenSource();
            var token = _debounce.Token;
            _ = Task.Run(async () =>
            {
                try
                {
                    await Task.Delay(DebounceMilliseconds, token);
                    Post();
                }
                catch (TaskCanceledException)
                {
                }
            }, token);
        }
    }

    static void Post()
    {
        var action = _onThemeSignal;
        if (action is null)
            return;

        if (_ui is { } ctx)
            ctx.Post(_ => action(), null);
        else
            action();
    }

    static string RuntimeDir()
        => Environment.GetEnvironmentVariable("XDG_RUNTIME_DIR") is { Length: > 0 } dir
            ? dir
            : Path.GetTempPath();
}

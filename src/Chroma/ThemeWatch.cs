using System.Net.Sockets;
using Qt.MetaObject;

namespace Omarchy.Chroma;

[Qt.Ignore]
public static class ThemeWatch
{
    static readonly object Gate = new();
    static Action? _onThemeSignal;
    static SynchronizationContext? _ui;
    static FileSystemWatcher? _currentWatcher;
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

        WatchCurrent();
        ListenSocket();
        WatchStamp();
    }

    public static void Stop()
    {
        _started = false;
        _listenCancel?.Cancel();
        _debounce?.Cancel();
        _currentWatcher?.Dispose();
        _stampWatcher?.Dispose();
        _listener?.Dispose();
        _currentWatcher = null;
        _stampWatcher = null;
        _listener = null;
    }

    static void WatchCurrent()
    {
        var home = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
        var path = Path.Combine(home, ".local", "state", "omarchy", "current");
        if (!Directory.Exists(path))
            return;

        var watcher = new FileSystemWatcher(path)
        {
            NotifyFilter = NotifyFilters.FileName | NotifyFilters.DirectoryName | NotifyFilters.LastWrite,
            IncludeSubdirectories = false,
            EnableRaisingEvents = true,
        };
        watcher.Changed += (_, _) => Signal();
        watcher.Created += (_, _) => Signal();
        watcher.Deleted += (_, _) => Signal();
        watcher.Renamed += (_, _) => Signal();
        _currentWatcher = watcher;
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
        catch
        {
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
                await Task.Delay(80, token);
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
            _debounce = new CancellationTokenSource();
            var token = _debounce.Token;
            _ = Task.Run(async () =>
            {
                try
                {
                    await Task.Delay(80, token);
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

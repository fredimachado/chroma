namespace Omarchy.Chroma;

public sealed class ThemeDirectoryMonitor : IDisposable
{
    const int DebounceMilliseconds = 80;
    const int AttachRetryInitialMilliseconds = 50;
    const int AttachRetryMaxMilliseconds = 2000;

    readonly object _gate = new();
    readonly string _root;
    CancellationTokenSource? _debounceCts;
    CancellationTokenSource? _attachRetryCts;
    FileSystemWatcher? _watcher;
    Action? _onChanged;
    bool _disposed;
    bool _started;

    public ThemeDirectoryMonitor(string? root = null)
    {
        _root = root ?? DefaultRoot();
    }

    public event Action? Changed;

    public static string DefaultRoot()
    {
        var home = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
        return Path.Combine(home, ".local", "state", "omarchy", "current");
    }

    public void Start(Action? onChanged = null)
    {
        lock (_gate)
        {
            ObjectDisposedException.ThrowIf(_disposed, this);
            if (_started)
                return;

            _onChanged = onChanged;
            _started = true;
            EnsureWatcher();
        }
    }

    public void Stop()
    {
        lock (_gate)
        {
            if (!_started)
                return;

            _started = false;
            CancelAndDisposeDebounce();
            CancelAttachRetry();
            DisposeWatcher();
        }
    }

    public void Dispose()
    {
        lock (_gate)
        {
            if (_disposed)
                return;

            _disposed = true;
            _started = false;
            CancelAndDisposeDebounce();
            CancelAttachRetry();
            DisposeWatcher();
        }
    }

    void EnsureWatcher()
    {
        if (TryAttachWatcher())
            return;

        ScheduleAttachRetry();
    }

    bool TryAttachWatcher()
    {
        if (!_started || _disposed)
            return false;

        DisposeWatcher();

        if (!Directory.Exists(_root))
            return false;

        FileSystemWatcher? watcher = null;
        try
        {
            watcher = new FileSystemWatcher(_root)
            {
                NotifyFilter = NotifyFilters.FileName | NotifyFilters.DirectoryName | NotifyFilters.LastWrite,
                IncludeSubdirectories = true,
                EnableRaisingEvents = false,
            };

            watcher.Changed += OnFileSystemEvent;
            watcher.Created += OnFileSystemEvent;
            watcher.Deleted += OnFileSystemEvent;
            watcher.Renamed += OnFileSystemEvent;
            watcher.EnableRaisingEvents = true;
            _watcher = watcher;
            CancelAttachRetry();
            return true;
        }
        catch
        {
            watcher?.Dispose();
            _watcher = null;
            return false;
        }
    }

    void OnFileSystemEvent(object sender, FileSystemEventArgs e) => ScheduleSignal();

    void ScheduleSignal()
    {
        lock (_gate)
        {
            if (!_started || _disposed)
                return;

            CancelAndDisposeDebounce();
            _debounceCts = new CancellationTokenSource();
            var token = _debounceCts.Token;
            _ = Task.Run(async () =>
            {
                try
                {
                    await Task.Delay(DebounceMilliseconds, token);
                }
                catch (TaskCanceledException)
                {
                    return;
                }

                var shouldRaise = false;
                lock (_gate)
                {
                    if (!_started || _disposed)
                        return;

                    EnsureWatcher();
                    shouldRaise = true;
                }

                if (shouldRaise)
                    RaiseChanged();
            });
        }
    }

    void ScheduleAttachRetry()
    {
        if (!_started || _disposed || _attachRetryCts is not null)
            return;

        _attachRetryCts = new CancellationTokenSource();
        var token = _attachRetryCts.Token;
        _ = Task.Run(async () =>
        {
            var delayMs = AttachRetryInitialMilliseconds;
            var succeeded = false;
            try
            {
                while (!token.IsCancellationRequested)
                {
                    try
                    {
                        await Task.Delay(delayMs, token);
                    }
                    catch (TaskCanceledException)
                    {
                        return;
                    }

                    lock (_gate)
                    {
                        if (token.IsCancellationRequested || !_started || _disposed)
                            return;

                        if (TryAttachWatcher())
                        {
                            succeeded = true;
                            return;
                        }

                        delayMs = Math.Min(delayMs * 2, AttachRetryMaxMilliseconds);
                    }
                }
            }
            finally
            {
                if (!succeeded)
                {
                    lock (_gate)
                    {
                        if (_attachRetryCts is not null && _attachRetryCts.Token == token)
                        {
                            _attachRetryCts.Dispose();
                            _attachRetryCts = null;
                        }
                    }
                }
            }
        });
    }

    void CancelAttachRetry()
    {
        if (_attachRetryCts is null)
            return;

        _attachRetryCts.Cancel();
        _attachRetryCts.Dispose();
        _attachRetryCts = null;
    }

    void CancelAndDisposeDebounce()
    {
        if (_debounceCts is null)
            return;

        _debounceCts.Cancel();
        _debounceCts.Dispose();
        _debounceCts = null;
    }

    void DisposeWatcher()
    {
        _watcher?.Dispose();
        _watcher = null;
    }

    void RaiseChanged()
    {
        Action? onChanged;
        Action? changedHandlers;
        lock (_gate)
        {
            if (!_started || _disposed)
                return;

            onChanged = _onChanged;
            changedHandlers = Changed;
        }

        onChanged?.Invoke();
        changedHandlers?.Invoke();
    }
}

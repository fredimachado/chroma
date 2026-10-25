namespace Omarchy.Chroma;

public sealed class ThemeDirectoryMonitor : IDisposable
{
    const int DebounceMilliseconds = 80;

    readonly object _gate = new();
    readonly string _root;
    CancellationTokenSource? _debounceCts;
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
        ObjectDisposedException.ThrowIf(_disposed, this);
        if (_started)
            return;

        _onChanged = onChanged;
        _started = true;
        AttachWatcher();
    }

    public void Stop()
    {
        if (!_started)
            return;

        _started = false;
        lock (_gate)
        {
            _debounceCts?.Cancel();
            _debounceCts = null;
        }

        _watcher?.Dispose();
        _watcher = null;
    }

    public void Dispose()
    {
        if (_disposed)
            return;

        _disposed = true;
        Stop();
    }

    void AttachWatcher()
    {
        _watcher?.Dispose();
        _watcher = null;

        if (!Directory.Exists(_root))
            return;

        var watcher = new FileSystemWatcher(_root)
        {
            NotifyFilter = NotifyFilters.FileName | NotifyFilters.DirectoryName | NotifyFilters.LastWrite,
            IncludeSubdirectories = true,
            EnableRaisingEvents = true,
        };

        watcher.Changed += OnFileSystemEvent;
        watcher.Created += OnFileSystemEvent;
        watcher.Deleted += OnFileSystemEvent;
        watcher.Renamed += OnFileSystemEvent;
        _watcher = watcher;
    }

    void OnFileSystemEvent(object sender, FileSystemEventArgs e) => ScheduleSignal();

    void ScheduleSignal()
    {
        if (!_started || _disposed)
            return;

        lock (_gate)
        {
            _debounceCts?.Cancel();
            _debounceCts = new CancellationTokenSource();
            var token = _debounceCts.Token;
            _ = Task.Run(async () =>
            {
                try
                {
                    await Task.Delay(DebounceMilliseconds, token);
                    if (_started && !_disposed)
                    {
                        AttachWatcher();
                        RaiseChanged();
                    }
                }
                catch (TaskCanceledException)
                {
                }
            }, token);
        }
    }

    void RaiseChanged()
    {
        _onChanged?.Invoke();
        Changed?.Invoke();
    }
}

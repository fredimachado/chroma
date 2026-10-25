if (args.Length < 1)
{
    Console.Error.WriteLine("Usage: SleepHost <pidFile> [seconds]");
    return 1;
}

File.WriteAllText(args[0], Environment.ProcessId.ToString());

var seconds = args.Length > 1 && int.TryParse(args[1], out var parsed) ? parsed : int.MaxValue / 1000;
Thread.Sleep(TimeSpan.FromSeconds(seconds));
return 0;

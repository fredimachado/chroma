using Qt.Quick;

namespace Omarchy.Chroma;

public static class Program
{
    internal static void Main(string[] args)
    {
        try
        {
            Palette.Instance.Reload();
            App.Instance.RefreshSession();
            Qml.LoadFromRootModule("Main");
            ThemeWatch.Start(() => Palette.Instance.QueueReload());
            Qml.WaitForExit();
        }
        finally
        {
            ThemeWatch.Stop();
        }
    }
}

using Qt.Quick;

namespace Omarchy.Chroma;

public static class Program
{
    internal static void Main(string[] args)
    {
        Palette.Instance.Reload();
        App.Instance.RefreshSession();
        Qml.LoadFromRootModule("Main");
        ThemeWatch.Start(() =>
        {
            Palette.Instance.Reload();
            App.Instance.RefreshSession();
        });
        Qml.WaitForExit();
    }
}

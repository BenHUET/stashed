namespace Tests.Unit;

public abstract class ServiceTests
{
    protected string TempDir { get; private set; }

    [SetUp]
    public void Setup()
    {
        TempDir = GetType().Name;

        var di = new DirectoryInfo(TempDir);
        if (di.Exists)
            di.Delete(true);

        di.Create();
    }
}
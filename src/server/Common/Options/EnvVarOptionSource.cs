namespace Stashed.Common.Options;

public class EnvVarOptionSource : IOptionSource
{
    public string? GetOption(string key)
    {
        return Environment.GetEnvironmentVariable(key);
    }
}
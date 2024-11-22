namespace Stashed.Common.Options;

public class DictOptionSource(Dictionary<string, string?> options) : IOptionSource
{
    public string? GetOption(string key)
    {
        return options.ContainsKey(key) ? options[key] : null;
    }
}
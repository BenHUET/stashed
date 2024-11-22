namespace Stashed.Common.Options;

public interface IOptionSource
{
    public string? GetOption(string key);
}
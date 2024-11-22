namespace Stashed.Core.Services;

public interface IHashService
{
    public Task<string> ComputeHash(byte[] content);
}
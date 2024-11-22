using System.Security.Cryptography;

namespace Stashed.Core.Services;

public interface IHashSha256Service : IHashService;

public class HashSha256Service : IHashSha256Service
{
    public async Task<string> ComputeHash(byte[] content)
    {
        var crypt = SHA256.Create();
        using var stream = new MemoryStream(content);
        var hash = await crypt.ComputeHashAsync(stream);
        return BitConverter.ToString(hash).Replace("-", string.Empty).ToLower();
    }
}
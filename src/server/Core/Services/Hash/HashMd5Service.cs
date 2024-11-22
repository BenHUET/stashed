using System.Security.Cryptography;

namespace Stashed.Core.Services;

public interface IHashMd5Service : IHashService;

public class HashMd5Service : IHashMd5Service
{
    public async Task<string> ComputeHash(byte[] content)
    {
        var crypt = MD5.Create();
        using var stream = new MemoryStream(content);
        var hash = await crypt.ComputeHashAsync(stream);
        return BitConverter.ToString(hash).Replace("-", string.Empty).ToLower();
    }
}
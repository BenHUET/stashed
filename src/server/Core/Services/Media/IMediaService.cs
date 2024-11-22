using Stashed.Common.Entities;

namespace Stashed.Core.Services;

public interface IMediaService
{
    public Task<Media> GetMedia(string vaultId, string storageId, string mediaId);
    public Task<Media> ImportMedia(string vaultId, string storageId, string filename, byte[] content);
}
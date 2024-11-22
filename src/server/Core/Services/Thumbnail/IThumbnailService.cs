using Stashed.Common.Entities;

namespace Stashed.Core.Services;

public interface IThumbnailService
{
    public Task<Thumbnail> GetThumbnail(string storageId, string sha256, int size);
    public Task<Thumbnail> GenerateThumbnail(string vaultId, string storageId, Lazy<Media> media, int size);
}
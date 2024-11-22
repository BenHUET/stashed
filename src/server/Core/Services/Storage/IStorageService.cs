using Stashed.Common.Entities;
using Stashed.Common.Models;

namespace Stashed.Core.Services;

public interface IStorageService
{
    public Task DeleteStorage(string storageId);
    public Task SaveMedia(string storageId, Media media);
    public Task SaveThumbnail(string storageId, Thumbnail thumbnail);
    public Task<byte[]> GetMedia(string storageId, string sha256);
    public Task<byte[]> GetThumbnail(string storageId, string sha256, int size);
    public Task DeleteMedia(string storageId, string sha256);
}

public interface IStorageService<TStorage> : IStorageService where TStorage : Storage
{
    public Task<TStorage> CreateStorage(IStorageCreateRequest<TStorage> request);
}
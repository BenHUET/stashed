using Stashed.Common.Entities;
using Stashed.Common.Models;

namespace Stashed.Common.Interfaces;

public interface ICoreController
{
    public Task<IEnumerable<Vault>> GetVaults();

    public Task<bool> HasVault(string vaultId);

    public Task<Vault> GetVault(string vaultId);

    public Task<TVault> CreateVaultWithStorage<TVault, TStorage>(IVaultCreateRequest<TVault> vaultRequest, IStorageCreateRequest<TStorage> storageRequest)
        where TStorage : Storage
        where TVault : Vault;

    public Task<TVault> UpdateVault<TVault>(string vaultId, TVault vault)
        where TVault : Vault;

    public Task DeleteVaultWithStorage(string vaultId);

    public Task<(MediaImportTrackedTask, IEnumerable<GenerateThumbnailTrackedTask>)> ImportMedia(string vaultId, string filename, byte[] content);

    public Task<IEnumerable<Media>> Search(string vaultId);

    public Task<Thumbnail> GetThumbnail(string vaultId, string mediaId, int size);

    public Task<Media> GetMedia(string vaultId, string mediaId);
}
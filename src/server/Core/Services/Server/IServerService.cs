using Stashed.Common.Entities;
using Stashed.Common.Models;

namespace Stashed.Core.Services.Server;

public interface IServerService
{
    public Task<bool> HasVault(string vaultId);
    public Task<Vault> GetVault(string vaultId);
    public Task<IEnumerable<Vault>> GetAllVaults();

    public Task<TVault> CreateVaultWithStorage<TVault, TStorage>(IVaultCreateRequest<TVault> vaultRequest, IStorageCreateRequest<TStorage> storageRequest)
        where TStorage : Storage
        where TVault : Vault;

    public Task DeleteVaultWithStorage(string vaultId);

    public Task<TVault> UpdateVault<TVault>(string vaultId, TVault vault)
        where TVault : Vault;

    public Task<Storage> GetStorage(string storageId);
    public Task<TStorage> GetStorage<TStorage>(string storageId) where TStorage : Storage;
    public Task<IEnumerable<Media>> Search(string vaultId);
}
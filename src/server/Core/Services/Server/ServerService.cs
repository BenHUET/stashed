using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.DependencyInjection;
using Stashed.Common.Contexts;
using Stashed.Common.Entities;
using Stashed.Common.Models;
using Stashed.Core.Factories;

namespace Stashed.Core.Services.Server;

public class ServerService(
    IServiceProvider serviceProvider,
    IMemoryCache memoryCache,
    ApplicationDbContext applicationDbContext,
    IVaultDbContextFactory vaultDbContextFactory,
    IStorageServiceFactory storageServiceFactory)
    : IServerService
{
    public async Task<bool> HasVault(string vaultId)
    {
        try
        {
            await GetVault(vaultId);
            return true;
        }
        catch (ArgumentException)
        {
            return false;
        }
    }

    public async Task<Vault> GetVault(string vaultId)
    {
        return await memoryCache.GetOrCreateAsync(
            $"vault_{vaultId}",
            entry => { return applicationDbContext.Vaults.AsNoTracking().Include(v => v.Storage).FirstOrDefaultAsync(v => v.Id == vaultId); }
        ) ?? throw new ArgumentException("No vault corresponding to the provided id");
    }

    public async Task<IEnumerable<Vault>> GetAllVaults()
    {
        return await applicationDbContext.Vaults.AsNoTracking().Include(v => v.Storage).ToListAsync();
    }

    public async Task<TVault> CreateVaultWithStorage<TVault, TStorage>(
        IVaultCreateRequest<TVault> vaultRequest,
        IStorageCreateRequest<TStorage> storageRequest)
        where TStorage : Storage
        where TVault : Vault
    {
        var typedVaultService = serviceProvider.GetService<IVaultService<TVault>>()!;
        var typedStorageService = serviceProvider.GetService<IStorageService<TStorage>>()!;

        TVault? vault = default;
        TStorage? storage = default;

        try
        {
            storage = await typedStorageService.CreateStorage(storageRequest);
            vault = await typedVaultService.CreateVault(vaultRequest, storage);
        }
        catch (Exception)
        {
            if (vault != null)
                await DeleteVaultWithStorage(vault.Id);

            if (storage != null)
                await typedStorageService.DeleteStorage(storage.Id);

            throw;
        }

        return vault;
    }

    public async Task DeleteVaultWithStorage(string vaultId)
    {
        var vaultDbContext = await vaultDbContextFactory.Get(vaultId);
        await vaultDbContext.Database.EnsureDeletedAsync();

        var vault = await GetVault(vaultId);

        if (vault.Storage != null)
        {
            var storageService = await storageServiceFactory.Get(vault.Storage.Id);
            await storageService.DeleteStorage(vault.Storage.Id);
        }

        applicationDbContext.Vaults.Remove(vault);
        await applicationDbContext.SaveChangesAsync();

        memoryCache.Remove($"vault_{vaultId}");
        memoryCache.Remove($"storage_{vaultId}");
    }

    public Task<TVault> UpdateVault<TVault>(string vaultId, TVault vault)
        where TVault : Vault
    {
        var service = serviceProvider.GetService<IVaultService<TVault>>()!;
        var result = service.UpdateVault(vaultId, vault);

        memoryCache.Remove($"vault_{vaultId}");

        return result;
    }

    public async Task<Storage> GetStorage(string storageId)
    {
        return await memoryCache.GetOrCreateAsync(
            $"storage_{storageId}",
            entry => { return applicationDbContext.Storages.AsNoTracking().FirstOrDefaultAsync(s => s.Id == storageId); }
        ) ?? throw new ArgumentException("No storage corresponding to the provided id");
    }

    public async Task<TStorage> GetStorage<TStorage>(string storageId) where TStorage : Storage
    {
        return (await GetStorage(storageId) as TStorage)!;
    }

    public async Task<IEnumerable<Media>> Search(string vaultId)
    {
        var context = await vaultDbContextFactory.Get(vaultId);
        return await context.Images.AsNoTracking().ToListAsync();
    }
}
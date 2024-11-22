using Microsoft.Extensions.DependencyInjection;
using Stashed.Common.Entities;
using Stashed.Common.Interfaces;
using Stashed.Common.Models;
using Stashed.Common.Services;
using Stashed.Core.Services;
using Stashed.Core.Services.Search;
using Stashed.Core.Services.Server;

namespace Stashed.Core.Controllers;

public class CoreController(
    ITaskQueue taskQueue,
    IServerService serverService,
    IThumbnailService thumbnailService,
    IMediaService mediaService,
    ISearchService searchService)
    : ICoreController
{
    // Server
    public Task<IEnumerable<Vault>> GetVaults()
    {
        return serverService.GetAllVaults();
    }

    public Task<bool> HasVault(string vaultId)
    {
        return serverService.HasVault(vaultId);
    }

    public Task<Vault> GetVault(string vaultId)
    {
        return serverService.GetVault(vaultId);
    }

    public Task<TVault> CreateVaultWithStorage<TVault, TStorage>(
        IVaultCreateRequest<TVault> vaultRequest,
        IStorageCreateRequest<TStorage> storageRequest)
        where TStorage : Storage
        where TVault : Vault
    {
        return serverService.CreateVaultWithStorage(vaultRequest, storageRequest);
    }

    public Task<TVault> UpdateVault<TVault>(string vaultId, TVault vault)
        where TVault : Vault
    {
        return serverService.UpdateVault(vaultId, vault);
    }

    public Task DeleteVaultWithStorage(string vaultId)
    {
        return serverService.DeleteVaultWithStorage(vaultId);
    }

    // Media
    public async Task<(MediaImportTrackedTask, IEnumerable<GenerateThumbnailTrackedTask>)> ImportMedia(string vaultId, string filename, byte[] content)
    {
        if (filename.Length == 0)
            throw new ArgumentException("Filename is empty");
        if (content.Length == 0)
            throw new ArgumentException("Content is empty");

        var vault = await serverService.GetVault(vaultId);

        var mediaImportTask = new MediaImportTrackedTask(
            provider => provider.GetRequiredService<IMediaService>().ImportMedia(vault.Id, vault.Storage!.Id, filename, content),
            vaultId
        );

        await taskQueue.EnqueueTask(mediaImportTask);

        var thumbnailGenerateTasks = new List<GenerateThumbnailTrackedTask>();
        foreach (var size in new[] { 64, 128, 256 })
        {
            var thumbnailGenerateTask = new GenerateThumbnailTrackedTask(
                provider =>
                {
                    return provider.GetRequiredService<IThumbnailService>().GenerateThumbnail(
                        vaultId,
                        vault.Storage!.Id,
                        new Lazy<Media>(() => mediaImportTask.Result!, LazyThreadSafetyMode.ExecutionAndPublication),
                        size
                    );
                },
                vaultId,
                mediaImportTask
            );

            thumbnailGenerateTasks.Add(thumbnailGenerateTask);
            await taskQueue.EnqueueTask(thumbnailGenerateTask);
        }

        return await Task.FromResult((mediaImportTask, thumbnailGenerateTasks));
    }

    public Task<IEnumerable<Media>> Search(string vaultId)
    {
        return searchService.SearchMedia(vaultId);
    }

    public async Task<Thumbnail> GetThumbnail(string vaultId, string mediaId, int size)
    {
        var vault = await serverService.GetVault(vaultId);
        return await thumbnailService.GetThumbnail(vault.Storage!.Id, mediaId, size);
    }

    public async Task<Media> GetMedia(string vaultId, string mediaId)
    {
        var vault = await serverService.GetVault(vaultId);
        return await mediaService.GetMedia(vault.Id, vault.Storage!.Id, mediaId);
    }
}
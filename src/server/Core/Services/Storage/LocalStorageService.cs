using Microsoft.Extensions.Logging;
using Stashed.Common;
using Stashed.Common.Entities;
using Stashed.Common.Models;
using Stashed.Common.Options;
using Stashed.Core.Services.Server;

namespace Stashed.Core.Services;

public class LocalStorageService(
    ILogger<LocalStorageService> logger,
    AppOptions appOptions,
    IServerService serverService)
    : IStorageService<LocalStorage>
{
    public async Task<LocalStorage> CreateStorage(IStorageCreateRequest<LocalStorage> request)
    {
        var localStorageWorkOrder = (LocalStorageCreateRequest)request;
        var storageId = Guid.NewGuid().ToString()[..8];
        var filesDirectory = string.IsNullOrEmpty(localStorageWorkOrder.FilesDirectory)
            ? Path.Combine(appOptions.LocalAppDataLocation, Constants.LocalStoragesDirectoryDefaultName, storageId)
            : localStorageWorkOrder.FilesDirectory;

        var directoryInfo = new DirectoryInfo(filesDirectory);

        try
        {
            if (directoryInfo.Exists && Directory.EnumerateFileSystemEntries(filesDirectory).Any())
                throw new ArgumentException($"Provided directory {filesDirectory} for local storage must be empty");

            new DirectoryInfo(filesDirectory).Create();
            await using var fileStream = File.Create(Path.Combine(filesDirectory, "test_write"), 1, FileOptions.DeleteOnClose);
        }
        catch (UnauthorizedAccessException)
        {
            throw new UnauthorizedAccessException($"Provided directory {filesDirectory} for local storage is not writable");
        }

        return new LocalStorage { Id = storageId, FilesDirectory = filesDirectory };
    }

    public async Task DeleteStorage(string storageId)
    {
        var baseDirectory = await GetBaseDirectory(storageId);
        Directory.Delete(baseDirectory, true);
    }

    public async Task<byte[]> GetMedia(string storageId, string sha256)
    {
        var (_, fileFullPath) = await GetFileDirectory(storageId, sha256, Constants.MediaDirectoryDefaultName, sha256);
        return await File.ReadAllBytesAsync(fileFullPath);
    }

    public async Task<byte[]> GetThumbnail(string storageId, string sha256, int size)
    {
        var (_, fileFullPath) = await GetFileDirectory(storageId, sha256, Constants.ThumbnailsDirectoryDefaultName, $"{sha256}_{size}");
        return await File.ReadAllBytesAsync(fileFullPath);
    }

    public async Task SaveMedia(string storageId, Media media)
    {
        var (directory, fileFullPath) = await GetFileDirectory(storageId, media.Sha256, Constants.MediaDirectoryDefaultName, media.Sha256);
        new DirectoryInfo(directory).Create();

        await File.WriteAllBytesAsync(fileFullPath, media.Content);

        logger.LogInformation("Wrote {FilePath}", fileFullPath);
    }

    public async Task SaveThumbnail(string storageId, Thumbnail thumbnail)
    {
        var (directory, fileFullPath)
            = await GetFileDirectory(storageId, thumbnail.OriginalSha256, Constants.ThumbnailsDirectoryDefaultName,
                $"{thumbnail.OriginalSha256}_{thumbnail.Size}");

        new DirectoryInfo(directory).Create();

        await File.WriteAllBytesAsync(fileFullPath, thumbnail.Content);

        logger.LogInformation("Wrote {FilePath}", fileFullPath);
    }

    public async Task DeleteMedia(string storageId, string sha256)
    {
        var (_, mediaFullPath) = await GetFileDirectory(storageId, sha256, Constants.MediaDirectoryDefaultName, sha256);
        File.Delete(mediaFullPath);

        logger.LogInformation("Deleted {FilePath}", mediaFullPath);

        await Task.CompletedTask;
    }

    private async Task<string> GetBaseDirectory(string storageId)
    {
        var storage = await serverService.GetStorage<LocalStorage>(storageId);
        return storage.FilesDirectory;
    }

    private async Task<(string, string)> GetFileDirectory(string storageId, string sha256, string intermediateDirectory, string filename)
    {
        var baseDirectory = await GetBaseDirectory(storageId);
        var directory = Path.Combine(baseDirectory, intermediateDirectory, InferSubDirectoryFromHash(sha256));
        var fileFullPath = Path.Combine(directory, filename);

        return (directory, fileFullPath);
    }

    private static string InferSubDirectoryFromHash(string hash)
    {
        var path = string.Empty;
        for (var i = 0; i < 4; i++)
            path = Path.Combine(path, hash.Substring(i, 1));

        return path;
    }
}
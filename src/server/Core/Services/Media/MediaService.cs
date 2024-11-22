using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using MimeTypes;
using Stashed.Common.Entities;
using Stashed.Core.Factories;
using Image = Stashed.Common.Entities.Image;

namespace Stashed.Core.Services;

public class MediaService(
    ILogger<MediaService> logger,
    IVaultDbContextFactory vaultDbContextFactory,
    IStorageServiceFactory storageServiceFactory,
    // ReSharper disable once SuggestBaseTypeForParameterInConstructor
    IHashSha256Service hashServiceSha256,
    // ReSharper disable once SuggestBaseTypeForParameterInConstructor
    IHashMd5Service hashServiceMd5)
    : IMediaService
{
    public async Task<Media> GetMedia(string vaultId, string storageId, string mediaId)
    {
        var context = await vaultDbContextFactory.Get(vaultId);
        var media = await context.Media.FirstOrDefaultAsync(m => m.Sha256 == mediaId);
        if (media == null)
            throw new ArgumentException("No media corresponding to the provided id");

        var storageService = await storageServiceFactory.Get(storageId);
        media.Content = await storageService.GetMedia(storageId, mediaId);

        return media;
    }

    public async Task<Media> ImportMedia(string vaultId, string storageId, string filename, byte[] content)
    {
        var fileExtension = new FileInfo(filename).Extension;
        var mimeType = MimeTypeMap.GetMimeType(fileExtension);

        if (mimeType == null || (!mimeType.StartsWith("image/") && !mimeType.StartsWith("video/") &&
                                 !mimeType.StartsWith("audio/")))
            throw new NotSupportedException();

        // File as bytes array
        using var stream = new MemoryStream();

        // Compute hashes
        var sha256 = await hashServiceSha256.ComputeHash(content);
        var md5 = await hashServiceMd5.ComputeHash(content);

        Media? media;

        if (mimeType.StartsWith("image/"))
        {
            var image = await BuildImage(sha256, md5, content, mimeType, filename);

            var context = await vaultDbContextFactory.Get(vaultId);
            await context.Images.AddAsync(image);
            await context.SaveChangesAsync();

            media = image;
        }
        else if (mimeType.StartsWith("video/"))
        {
            throw new NotSupportedException("Video formats not supported");
        }
        else if (mimeType.StartsWith("audio/"))
        {
            throw new NotSupportedException("Audio formats not supported");
        }
        else
        {
            throw new NotSupportedException();
        }

        // Persist file
        var storageService = await storageServiceFactory.Get(storageId);
        await storageService.SaveMedia(storageId, media);

        logger.LogInformation("Imported file {FileName}", media.FileName);

        return media;
    }

    private static async Task<Image> BuildImage(string sha256, string md5, byte[] content, string mimeType, string filename)
    {
        using var memoryStreamIn = new MemoryStream(content);
        using var image = await SixLabors.ImageSharp.Image.LoadAsync(memoryStreamIn);

        return new Image
        {
            Sha256 = sha256,
            Md5 = md5,
            Content = content,
            MimeType = mimeType,
            FileName = filename,
            Width = image.Width,
            Height = image.Height,
            Size = content.Length,
            Tags = []
        };
    }
}
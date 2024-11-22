using Microsoft.Extensions.Logging;
using SixLabors.ImageSharp.Formats.Png;
using SixLabors.ImageSharp.Processing;
using Stashed.Common.Entities;
using Stashed.Core.Factories;
using Image = Stashed.Common.Entities.Image;

namespace Stashed.Core.Services;

public class ThumbnailService(ILogger<ThumbnailService> logger, IStorageServiceFactory storageServiceFactory) : IThumbnailService
{
    private readonly ILogger<IThumbnailService> _logger = logger;

    public async Task<Thumbnail> GetThumbnail(string storageId, string sha256, int size)
    {
        var storageService = await storageServiceFactory.Get(storageId);

        return new Thumbnail
        {
            OriginalSha256 = sha256,
            Content = await storageService.GetThumbnail(storageId, sha256, size),
            Size = size
        };
    }

    public async Task<Thumbnail> GenerateThumbnail(string vaultId, string storageId, Lazy<Media> media, int size)
    {
        Thumbnail thumbnail;

        // Image
        if (media.Value is Image entity)
        {
            using var memoryStreamIn = new MemoryStream(entity.Content);
            using var image = await SixLabors.ImageSharp.Image.LoadAsync(memoryStreamIn);

            var targetHeight = image.Height > image.Width ? size : 0;
            var targetWidth = targetHeight == 0 ? size : 0;

            image.Mutate(x => x.Resize(targetWidth, targetHeight, KnownResamplers.Bicubic));

            using var memoryStreamOut = new MemoryStream();
            await image.SaveAsync(memoryStreamOut, new PngEncoder());

            thumbnail = new Thumbnail
            {
                OriginalSha256 = media.Value.Sha256,
                Content = memoryStreamOut.ToArray(),
                Size = size
            };

            var storageService = await storageServiceFactory.Get(storageId);
            await storageService.SaveThumbnail(storageId, thumbnail);

            _logger.LogInformation(
                "Created thumbnail {Width}x{Height} for media {MediaSha256} in vault {VaultId} (storage {StorageId})",
                image.Width,
                image.Height,
                media.Value.Sha256,
                vaultId,
                storageId
            );
        }
        else
        {
            throw new NotImplementedException();
        }

        return thumbnail;
    }
}
using Microsoft.Extensions.Logging.Abstractions;
using MockQueryable.Moq;
using Moq;
using Stashed.Common.Entities;
using Stashed.Core.Contexts;
using Stashed.Core.Factories;
using Stashed.Core.Services;

namespace Tests.Unit;

public class MediaServiceTests : ServiceTests
{
    private MediaService _service;

    [SetUp]
    public new void Setup()
    {
        base.Setup();

        var storageService = new Mock<IStorageService>();

        var storageServiceFactory = new Mock<IStorageServiceFactory>();
        storageServiceFactory.Setup(x => x.Get(It.IsAny<string>())).Returns(Task.FromResult(storageService.Object));

        var hashSha256Service = new Mock<IHashSha256Service>();
        hashSha256Service.Setup(s => s.ComputeHash(It.IsAny<byte[]>())).Returns(Task.FromResult("aaa"));

        var hashMd5Service = new Mock<IHashMd5Service>();
        hashMd5Service.Setup(s => s.ComputeHash(It.IsAny<byte[]>())).Returns(Task.FromResult("aaa"));

        var dbSetImages = new List<Image>().AsQueryable().BuildMockDbSet();

        var vaultDbContext = new Mock<VaultDbContext>();
        vaultDbContext.Setup(x => x.Images).Returns(dbSetImages.Object);

        var vaultDbContextFactory = new Mock<IVaultDbContextFactory>();
        vaultDbContextFactory
            .Setup(x => x.Get(It.IsAny<string>()))
            .Returns(() => Task.FromResult(vaultDbContext.Object));

        _service = new MediaService(
            NullLogger<MediaService>.Instance,
            vaultDbContextFactory.Object,
            storageServiceFactory.Object,
            hashSha256Service.Object,
            hashMd5Service.Object
        );
    }

    [Test]
    public Task Import_accepts_image_formats()
    {
        Assert.DoesNotThrowAsync(async Task () =>
        {
            try
            {
                await _service.ImportMedia(string.Empty, string.Empty, "file.png", "content"u8.ToArray());
            }
            catch (NotSupportedException)
            {
                throw;
            }
            catch
            {
                // This will swallow any other exceptions since we're only interested in NotSupportedException
            }
        });

        return Task.CompletedTask;
    }

    [Test]
    public Task Import_rejects_audio_formats()
    {
        Assert.ThrowsAsync<NotSupportedException>(async Task () =>
        {
            await _service.ImportMedia(string.Empty, string.Empty, "file.mp3", "content"u8.ToArray());
        });

        return Task.CompletedTask;
    }

    [Test]
    public Task Import_rejects_video_formats()
    {
        Assert.ThrowsAsync<NotSupportedException>(async Task () =>
        {
            await _service.ImportMedia(string.Empty, string.Empty, "file.webm", "content"u8.ToArray());
        });

        return Task.CompletedTask;
    }
}
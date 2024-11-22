using System.Text;
using FluentAssertions;
using Microsoft.Extensions.Logging.Abstractions;
using Moq;
using Stashed.Common;
using Stashed.Common.Entities;
using Stashed.Common.Models;
using Stashed.Common.Options;
using Stashed.Core.Services;
using Stashed.Core.Services.Server;

namespace Tests.Unit;

public class LocalStorageServiceTests : ServiceTests
{
    private LocalStorageService _localStorageService;
    private AppOptions _options;

    [SetUp]
    public void SetUp()
    {
        _options = new AppOptions(TempDir);

        var serverService = new Mock<IServerService>();
        serverService.Setup(s => s.GetStorage<LocalStorage>(It.IsAny<string>()))
            .Returns(() => Task.FromResult(new LocalStorage { Id = "A", FilesDirectory = TempDir }));

        _localStorageService = new LocalStorageService(
            NullLogger<LocalStorageService>.Instance,
            _options,
            serverService.Object
        );
    }

    [Test]
    public async Task Save_media_to_good_folder()
    {
        var content = "abcdef"u8.ToArray();
        const string contentHash = "a1b2c3d4e5f60000000000";

        var storageService = _localStorageService;

        await storageService.SaveMedia("A",
            new Image
            {
                Content = content,
                Sha256 = contentHash,
                Md5 = "dummy",
                MimeType = "dummy",
                Height = 0,
                Width = 0,
                Size = 0,
                FileName = null,
                Tags = []
            });

        File.Exists(Path.Combine(TempDir, Constants.MediaDirectoryDefaultName, "a", "1", "b", "2", contentHash)).Should().BeTrue();

        await Task.CompletedTask;
    }

    [Test]
    public async Task Save_thumbnails_to_good_folder()
    {
        var thumbnail = new Thumbnail
        {
            OriginalSha256 = "a1b2c3d4e5f60000000000",
            Content = "abcdef"u8.ToArray(),
            Size = 128
        };

        var storageService = _localStorageService;

        await storageService.SaveThumbnail("A", thumbnail);

        File.Exists(Path.Combine(TempDir, Constants.ThumbnailsDirectoryDefaultName, "a", "1", "b", "2", $"{thumbnail.OriginalSha256}_{thumbnail.Size}"))
            .Should().BeTrue();

        await Task.CompletedTask;
    }

    [Test]
    public async Task Load_media_from_hash()
    {
        const string contentAsString = "hello hello";
        var subDirectory = Path.Combine(TempDir, Constants.MediaDirectoryDefaultName, "e", "e", "a", "c");

        new DirectoryInfo(subDirectory).Create();

        await File.WriteAllBytesAsync(Path.Combine(subDirectory, "eeac01234"), Encoding.ASCII.GetBytes(contentAsString));

        var storageService = _localStorageService;

        var content = await storageService.GetMedia("A", "eeac01234");

        Encoding.ASCII.GetString(content).Should().Be(contentAsString);

        await Task.CompletedTask;
    }

    [Test]
    public async Task Delete_media_from_hash()
    {
        var subDirectory = Path.Combine(TempDir, Constants.MediaDirectoryDefaultName, "e", "e", "a", "c");
        new DirectoryInfo(subDirectory).Create();

        await File.WriteAllBytesAsync(Path.Combine(subDirectory, "eeac01234"), "helloworld"u8.ToArray());

        var storageService = _localStorageService;

        File.Exists(Path.Combine(TempDir, Constants.MediaDirectoryDefaultName, "e", "e", "a", "c", "eeac01234")).Should().BeTrue();

        await storageService.DeleteMedia("A", "eeac01234");

        File.Exists(Path.Combine(TempDir, Constants.MediaDirectoryDefaultName, "e", "e", "a", "c", "eeac01234")).Should().BeFalse();

        await Task.CompletedTask;
    }

    [Test]
    public async Task Delete_storage()
    {
        var storageService = _localStorageService;
        await storageService.SaveMedia("A",
            new Image
            {
                Content = Array.Empty<byte>(), Sha256 = "dummy", Md5 = "dummy", MimeType = "dummy", Height = 0, Size = 0, Width = 0, FileName = null, Tags = []
            });
        Directory.Exists(TempDir).Should().BeTrue();
        await storageService.DeleteStorage("A");
        Directory.Exists(TempDir).Should().BeFalse();
    }

    [Test]
    public async Task Throw_on_not_empty_files_directory()
    {
        var path = Path.Combine(TempDir, "notEmptyDirectory");

        var directoryInfo = new DirectoryInfo(path);
        directoryInfo.Create();

        await File.WriteAllTextAsync(Path.Combine(path, "file1"), "content");

        Assert.ThrowsAsync<ArgumentException>(async Task () => { await _localStorageService.CreateStorage(new LocalStorageCreateRequest(path)); });
    }
}
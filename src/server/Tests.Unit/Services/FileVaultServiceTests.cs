using System.Runtime.InteropServices;
using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.VisualStudio.TestPlatform.ObjectModel;
using Moq;
using Stashed.Common.Contexts;
using Stashed.Common.Entities;
using Stashed.Common.Models;
using Stashed.Common.Options;
using Stashed.Core.Services;
using Constants = Stashed.Common.Constants;

namespace Tests.Unit;

public class FileVaultServiceTests : ServiceTests
{
    private FileVaultService _service;

    [SetUp]
    public new void Setup()
    {
        var options = new AppOptions(TempDir);

        var dbSetFileVaults = new Mock<DbSet<FileVault>>();

        var applicationDbContext = new Mock<ApplicationDbContext>();
        applicationDbContext.Setup(x => x.FileVaults).Returns(dbSetFileVaults.Object);

        _service = new FileVaultService(
            NullLogger<FileVaultService>.Instance,
            options,
            applicationDbContext.Object
        );
    }

    [Test]
    public async Task Create_to_default_folder()
    {
        var result = await _service.CreateVault(new FileVaultCreateRequest(null, null));
        File.Exists(Path.Combine(TempDir, Constants.FileVaultsDirectoryDefaultName, $"{result.Id}.sqlite")).Should().BeTrue();

        await Task.CompletedTask;
    }

    [Test]
    public async Task Create_to_specific_folder()
    {
        var path = Path.Combine(TempDir, "tests");
        new DirectoryInfo(path).Create();
        var result = await _service.CreateVault(new FileVaultCreateRequest(null, path));
        File.Exists(Path.Combine(path, $"{result.Id}.sqlite")).Should().BeTrue();

        await Task.CompletedTask;
    }

    [Test]
    public Task Create_fail_unwritable_folder()
    {
        string path;
        if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
            path = Environment.GetFolderPath(Environment.SpecialFolder.System);
        else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
            path = "/";
        else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
            path = "/";
        else
            throw new TestPlatformException("This test is not supported on this platform.");

        Assert.ThrowsAsync<UnauthorizedAccessException>(async Task () =>
            await _service.CreateVault(new FileVaultCreateRequest(null, path)));

        return Task.CompletedTask;
    }
}
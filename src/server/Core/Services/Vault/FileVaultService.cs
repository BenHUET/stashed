using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Stashed.Common;
using Stashed.Common.Contexts;
using Stashed.Common.Entities;
using Stashed.Common.Exceptions;
using Stashed.Common.Models;
using Stashed.Common.Options;
using Stashed.Core.Contexts;
using Stashed.Core.Extensions;

namespace Stashed.Core.Services;

public class FileVaultService(
    ILogger<FileVaultService> logger,
    AppOptions appOptions,
    ApplicationDbContext applicationDbContext)
    : IVaultService<FileVault>
{
    public async Task<FileVault> CreateVault(IVaultCreateRequest<FileVault> request, Storage? storage = null)
    {
        var fileVaultWorkOrder = (FileVaultCreateRequest)request;
        var guid = Guid.NewGuid().ToString()[..8];

        var vault = new FileVault
        {
            Id = guid,
            Label = string.IsNullOrEmpty(fileVaultWorkOrder.Label) ? guid : fileVaultWorkOrder.Label,
            DatabaseDirectory = string.IsNullOrEmpty(fileVaultWorkOrder.DatabaseDirectory)
                ? Path.Combine(appOptions.LocalAppDataLocation, Constants.FileVaultsDirectoryDefaultName)
                : fileVaultWorkOrder.DatabaseDirectory,
            Storage = storage
        };

        try
        {
            // Create the actual file
            var path = vault.GetFullPath();
            new FileInfo(path).Directory?.Create();

            var context = new SqliteVaultDbContext(vault.GetFullPath());

            await context.Database.EnsureCreatedAsync();

            await applicationDbContext.FileVaults.AddAsync(vault);
            await applicationDbContext.SaveChangesAsync();

            logger.LogInformation("New vault {VaultID} created at {VaultPath}", vault.Id, vault.DatabaseDirectory);
            return vault;
        }
        catch (SqliteException e) when (e.SqliteErrorCode == 14)
        {
            throw new UnauthorizedAccessException($"Can't write database file to {vault.GetFullPath()}", e);
        }
    }

    public async Task<FileVault> UpdateVault(string vaultId, FileVault updatedVault)
    {
        var original = await applicationDbContext
            .FileVaults
            .FirstOrDefaultAsync(v => v.Id == vaultId);

        if (original == null)
            throw new ArgumentException("No vault corresponding to the provided id");

        if (original.Id != updatedVault.Id || original.DatabaseDirectory != updatedVault.DatabaseDirectory)
            throw new ProtectedFieldException("Updating protected fields is forbidden");

        applicationDbContext.Entry(original).CurrentValues.SetValues(updatedVault);
        await applicationDbContext.SaveChangesAsync();

        return updatedVault;
    }
}
using Microsoft.EntityFrameworkCore;
using Stashed.Common.Contexts;
using Stashed.Common.Entities;
using Stashed.Core.Contexts;
using Stashed.Core.Extensions;

namespace Stashed.Core.Factories;

public class VaultDbContextFactory(ApplicationDbContext applicationDbContext) : IVaultDbContextFactory
{
    public async Task<VaultDbContext> Get(string vaultId)
    {
        var vault = await applicationDbContext.Vaults.FirstOrDefaultAsync(v => v.Id == vaultId);
        return vault switch
        {
            FileVault filevault => new SqliteVaultDbContext(filevault.GetFullPath()),
            null => throw new ArgumentException("No vault corresponding to the provided id"),
            _ => throw new NotImplementedException()
        };
    }
}
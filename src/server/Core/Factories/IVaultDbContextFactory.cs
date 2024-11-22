using Stashed.Core.Contexts;

namespace Stashed.Core.Factories;

public interface IVaultDbContextFactory
{
    public Task<VaultDbContext> Get(string vaultId);
}
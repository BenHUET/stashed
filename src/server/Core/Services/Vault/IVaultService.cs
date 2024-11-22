using Stashed.Common.Entities;
using Stashed.Common.Models;

namespace Stashed.Core.Services;

public interface IVaultService<TVault> where TVault : Vault
{
    public Task<TVault> CreateVault(IVaultCreateRequest<TVault> request, Storage? storage);
    public Task<TVault> UpdateVault(string vaultId, TVault vault);
}
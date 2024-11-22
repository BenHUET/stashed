using Stashed.Common.Entities;

namespace Stashed.Common.Models;

// ReSharper disable once UnusedTypeParameter
public interface IVaultCreateRequest<TVault> where TVault : Vault;

public record FileVaultCreateRequest(
    string? Label,
    string? DatabaseDirectory
) : IVaultCreateRequest<FileVault>;
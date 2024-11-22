using Microsoft.EntityFrameworkCore;

namespace Stashed.Common.Entities;

[PrimaryKey(nameof(UserId), nameof(RoleId), nameof(VaultId))]
public class UserRole
{
    public required string UserId { get; init; }
    public required int RoleId { get; init; }
    public required string VaultId { get; init; }

    public User User { get; init; }
    public Role Role { get; init; }
    public Vault Vault { get; init; }
}
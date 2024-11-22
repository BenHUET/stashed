using System.ComponentModel.DataAnnotations;

namespace Stashed.Common.Entities;

public class User
{
    [Key] public required string Id { get; init; }
    [Required] public required string Username { get; init; }
    [Required] public required bool IsAdmin { get; init; }

    public ICollection<UserRole> UserRoleByVaults { get; } = [];
}
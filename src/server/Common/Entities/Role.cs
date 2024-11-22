using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Stashed.Common.Models.Permissions;

namespace Stashed.Common.Entities;

public class Role
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public required int Id { get; init; }

    [Required] public required string Name { get; init; }
    public required List<PermissionType> Permissions { get; init; }
}
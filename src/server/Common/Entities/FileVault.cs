using System.ComponentModel.DataAnnotations;

namespace Stashed.Common.Entities;

public class FileVault : Vault
{
    [Required] public required string DatabaseDirectory { get; init; }
}
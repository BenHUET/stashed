using System.ComponentModel.DataAnnotations;

namespace Stashed.Common.Entities;

public abstract class Vault
{
    [Key] public required string Id { get; init; }
    [Required] public required string Label { get; init; }
    public Storage? Storage { get; init; }
}
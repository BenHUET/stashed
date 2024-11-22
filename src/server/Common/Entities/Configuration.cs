using System.ComponentModel.DataAnnotations;

namespace Stashed.Common.Entities;

public class Configuration
{
    [Key] public required string Key { get; init; }
    [Required] public required string Value { get; init; }
}
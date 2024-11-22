using System.ComponentModel.DataAnnotations;

namespace Stashed.Common.Entities;

public abstract class Storage
{
    [Key] public required string Id { get; init; }
}
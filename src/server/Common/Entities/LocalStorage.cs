using System.ComponentModel.DataAnnotations;

namespace Stashed.Common.Entities;

public class LocalStorage : Storage
{
    [Required] public required string FilesDirectory { get; init; }
}
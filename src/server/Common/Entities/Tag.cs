using System.ComponentModel.DataAnnotations;

namespace Stashed.Common.Entities;

public class Tag
{
    [Key] public required string Name { get; set; }
    public required List<Media> Medias { get; init; }
}
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Stashed.Common.Entities;

public abstract class Media
{
    [Key] public required string Sha256 { get; init; }
    [Required] public required string Md5 { get; init; }
    [Required] public required string MimeType { get; init; }
    public required string? FileName { get; init; }
    [Required] public required int Size { get; init; }
    [Required] public required int Width { get; init; }
    [Required] public required int Height { get; init; }
    public required List<Tag> Tags { get; init; }
    [NotMapped] public required byte[] Content { get; set; }
}
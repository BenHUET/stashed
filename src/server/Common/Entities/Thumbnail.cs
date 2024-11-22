namespace Stashed.Common.Entities;

public class Thumbnail
{
    public required string OriginalSha256 { get; init; }
    public required byte[] Content { get; init; }
    public int Size { get; init; }
}
using JetBrains.Annotations;

namespace Stashed.Common.DTOs;

[PublicAPI]
public record LocalStorageCreateRequestDto(
    string? FilesDirectory
);
using JetBrains.Annotations;

namespace Stashed.Common.DTOs;

[PublicAPI]
public record FileVaultCreateRequestDto(
    string? Label,
    string? DatabaseDirectory
);
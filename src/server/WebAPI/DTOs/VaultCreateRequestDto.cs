using System.Text.Json.Serialization;
using JetBrains.Annotations;
using Newtonsoft.Json;

namespace Stashed.Common.DTOs;

[PublicAPI]
public record VaultCreateRequestDto(
    [property: JsonPropertyName("FileVault")]
    [property: JsonProperty("FileVault")]
    FileVaultCreateRequestDto? FileVaultCreateRequestDto,
    [property: JsonPropertyName("LocalStorage")]
    [property: JsonProperty("LocalStorage")]
    LocalStorageCreateRequestDto? LocalStorageCreateRequestDto
);
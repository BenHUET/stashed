using JetBrains.Annotations;
using Newtonsoft.Json;
using Stashed.Common.Entities;

namespace Stashed.Common.DTOs;

[PublicAPI]
public record FileVaultEntityDto(
    string Id,
    string Label,
    string DatabaseDirectory,
    [property: JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
    LocalStorage? LocalStorage = null
)
{
    public FileVaultEntityDto(FileVault vault)
        : this(vault.Id, vault.Label, vault.DatabaseDirectory)
    {
    }

    public FileVaultEntityDto(FileVault vault, LocalStorage storage) : this(vault)
    {
        LocalStorage = storage;
    }
}
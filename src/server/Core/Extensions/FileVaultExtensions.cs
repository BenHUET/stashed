using Stashed.Common.Entities;

namespace Stashed.Core.Extensions;

public static class FileVaultExtensions
{
    public static string GetFullPath(this FileVault vault)
    {
        return Path.Combine(vault.DatabaseDirectory, $"{vault.Id}.sqlite");
    }
}
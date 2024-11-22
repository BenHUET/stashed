namespace Stashed.Common.Options;

public enum DatabaseProvider
{
    Sqlite,
    Postgresql
}

public record AppOptions(
    string LocalAppDataLocation,
    string? Port = null,
    string? Hostname = null,
    DatabaseProvider DatabaseProvider = DatabaseProvider.Sqlite,
    string? DatabaseHost = null,
    string? DatabaseName = null,
    string? DatabaseUser = null,
    string? DatabasePassword = null,
    string? DatabasePath = null,
    bool AuthEnabled = true,
    string? AuthAdminUserId = null,
    string? AuthAdminUsername = null
)
{
    public string ConnectionString => $"Host={DatabaseHost};Database={DatabaseName};Username={DatabaseUser};Password={DatabasePassword}";
}
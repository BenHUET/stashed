using System.Text;

namespace Stashed.Common.Options;

// Could replace with the built-in way to handle Options but this will also result in a mess 
public static class AppOptionsBuilder
{
    public static AppOptions GetOptions(IList<IOptionSource> sources)
    {
        var localAppDataDirectory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), Constants.AppName);

        var databaseProvider = GetOption(sources, "DB_TYPE") == "pgsql" ? DatabaseProvider.Postgresql : DatabaseProvider.Sqlite;

        var port = GetOption(sources, "PORT") ?? "16827";

        var databasePath = string.IsNullOrEmpty(GetOption(sources, "DB_PATH"))
            ? Path.Combine(localAppDataDirectory, Constants.DefaultGlobalDatabase)
            : GetOption(sources, "DB_PATH");

        var appOptions = new AppOptions(
            localAppDataDirectory,
            port,
            GetOption(sources, "HOSTNAME"),
            databaseProvider,
            GetOption(sources, "DB_HOST"),
            GetOption(sources, "DB_NAME"),
            GetOption(sources, "DB_USER"),
            GetOption(sources, "DB_PASSWORD"),
            databasePath,
            GetOption(sources, "AUTH_ENABLED") != "false",
            GetOption(sources, "AUTH_ADMIN_ID"),
            GetOption(sources, "AUTH_ADMIN_USERNAME")
        );

        var errorStringBuilder = new StringBuilder();

        if (appOptions.DatabaseProvider == DatabaseProvider.Postgresql)
        {
            if (!int.TryParse(appOptions.Port, out _))
                errorStringBuilder.AppendLine("Invalid PORT environment variable");
            if (string.IsNullOrEmpty(appOptions.DatabaseHost))
                errorStringBuilder.AppendLine("Missing DB_HOST environment variable");
            if (string.IsNullOrEmpty(appOptions.DatabaseName))
                errorStringBuilder.AppendLine("Missing DB_NAME environment variable");
            if (string.IsNullOrEmpty(appOptions.DatabaseUser))
                errorStringBuilder.AppendLine("Missing DB_USER environment variable");
            if (string.IsNullOrEmpty(appOptions.DatabasePassword))
                errorStringBuilder.AppendLine("Missing DB_PASSWORD environment variable");
        }

        if (appOptions.AuthEnabled)
        {
            if (string.IsNullOrEmpty(appOptions.AuthAdminUserId))
                errorStringBuilder.AppendLine("Missing AUTH_ADMIN_ID environment variable (the ID of a beeapps.org account)");
            if (string.IsNullOrEmpty(appOptions.Hostname))
                errorStringBuilder.AppendLine("Missing HOSTNAME environment variable");
        }

        if (errorStringBuilder.Length > 0)
            throw new ArgumentException(errorStringBuilder.ToString());

        return appOptions;
    }

    // ReSharper disable once ParameterTypeCanBeEnumerable.Local
    private static string? GetOption(IList<IOptionSource> sources, string key)
    {
        foreach (var source in sources)
        {
            var option = source.GetOption(key);
            if (option != null)
                return option;
        }

        return null;
    }
}
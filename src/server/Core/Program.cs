using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Stashed.Common;
using Stashed.Common.Contexts;
using Stashed.Common.Entities;
using Stashed.Common.Interfaces;
using Stashed.Common.Options;
using Stashed.Common.Services;
using Stashed.Core.Controllers;
using Stashed.Core.Factories;
using Stashed.Core.Services;
using Stashed.Core.Services.Search;
using Stashed.Core.Services.Server;
using Stashed.WebAPI;

var builder = new HostApplicationBuilder();

// Logging
builder.Services.AddLogging(c =>
{
    c.AddSimpleConsole(o => { o.TimestampFormat = "[HH:mm:ss] "; });
    c.AddFilter(null, LogLevel.Information);
});

// Databases
builder.Services.AddDbContext<ApplicationDbContext>((scope, options) =>
{
    var appOptions = scope.GetRequiredService<AppOptions>();
    if (appOptions.DatabaseProvider == DatabaseProvider.Postgresql)
        options.UseNpgsql(appOptions.ConnectionString);
    else if (appOptions.DatabaseProvider == DatabaseProvider.Sqlite)
        options.UseSqlite($"Data Source={appOptions.DatabasePath}");
}, ServiceLifetime.Transient);

builder.Services.AddTransient<IVaultDbContextFactory, VaultDbContextFactory>();

// Cache
builder.Services.AddMemoryCache();

// Options
builder.Services.AddSingleton<AppOptions>(_ => AppOptionsBuilder.GetOptions([new EnvVarOptionSource()]));

// Custom services
builder.Services.AddTransient<IServerService, ServerService>();
builder.Services.AddTransient<IStorageServiceFactory, StorageServiceFactory>();
builder.Services.AddTransient<IStorageService<LocalStorage>, LocalStorageService>();
builder.Services.AddTransient<IVaultService<FileVault>, FileVaultService>();
builder.Services.AddTransient<IThumbnailService, ThumbnailService>();
builder.Services.AddTransient<IMediaService, MediaService>();
builder.Services.AddTransient<ISearchService, SearchService>();
builder.Services.AddTransient<IHashSha256Service, HashSha256Service>();
builder.Services.AddTransient<IHashMd5Service, HashMd5Service>();
builder.Services.AddTransient<ICoreController, CoreController>();

// Queue
for (var i = 0; i < 1; i++)
    builder.Services.AddSingleton<IHostedService, QueueWorkerBackgroundService>();
builder.Services.AddSingleton<ITaskQueue, TrackedTaskQueue>();

// Web API
builder.Services.AddHostedService<WebApi>();

var app = builder.Build();

using var scope = app.Services.CreateScope();
var appOptions = scope.ServiceProvider.GetRequiredService<AppOptions>();

// Create local app data directory
Directory.CreateDirectory(appOptions.LocalAppDataLocation);

// Create database if it doesn't exist
var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
await context.Database.EnsureDeletedAsync();
var isNewDatabase = await context.Database.EnsureCreatedAsync();

if (isNewDatabase)
{
    // Create admin user
    if (appOptions.AuthEnabled)
    {
        var user = new User
        {
            Id = appOptions.AuthAdminUserId!,
            IsAdmin = true,
            Username = appOptions.AuthAdminUsername ?? "admin"
        };

        await context.Users.AddAsync(user);
    }

    await context.Configurations.AddAsync(new Configuration { Key = Constants.ConfigAuthEnabledKey, Value = appOptions.AuthEnabled.ToString() });

    await context.SaveChangesAsync();
}
else
{
    var configuration = await context.Configurations.FirstOrDefaultAsync(c => c.Key == Constants.ConfigAuthEnabledKey);
    if (configuration?.Value != appOptions.AuthEnabled.ToString())
        throw new ArgumentException(
            "Configuration mismatch. App is trying to run with authentication enabled but database was created without it. Or the other way around. Either fix configuration or delete the database.");
}

app.Run();
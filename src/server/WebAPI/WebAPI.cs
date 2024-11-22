using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Keycloak.AuthServices.Authentication;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.ApplicationParts;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Stashed.Common.Contexts;
using Stashed.Common.Interfaces;
using Stashed.Common.Models.Permissions;
using Stashed.Common.Options;
using Stashed.Common.Services;
using Stashed.WebAPI.Auth;
using Stashed.WebAPI.Controllers;
using Stashed.WebAPI.Hubs;
using Stashed.WebAPI.Services;

namespace Stashed.WebAPI;

public class WebApi : IHostedService
{
    private readonly WebApplication _app;

    public WebApi(IServiceProvider serviceProvider, AppOptions appOptions)
    {
        var builder = WebApplication.CreateBuilder();

        // Register controllers from this assembly
        var assembly = typeof(MediaController).Assembly;
        builder
            .Services
            .AddControllers()
            .AddNewtonsoftJson()
            .PartManager
            .ApplicationParts
            .Add(new AssemblyPart(assembly));

        // Websocket
        builder.Services.AddSignalR().AddNewtonsoftJsonProtocol();
        builder.WebHost.UseUrls($"http://*:{appOptions.Port}");

        // Options
        builder.Services.AddSingleton<AppOptions>(_ => serviceProvider.GetRequiredService<AppOptions>());

        // Databases
        builder.Services.AddDbContext<ApplicationDbContext>((scope, options) =>
        {
            var scopedOptions = scope.GetRequiredService<AppOptions>();
            if (scopedOptions.DatabaseProvider == DatabaseProvider.Postgresql)
                options.UseNpgsql(scopedOptions.ConnectionString);
            else if (scopedOptions.DatabaseProvider == DatabaseProvider.Sqlite)
                options.UseSqlite($"Data Source={scopedOptions.DatabasePath}");
        }, ServiceLifetime.Transient);

        // Authentication (keycloak)
        if (appOptions.AuthEnabled)
        {
            builder.Services.AddKeycloakAuthentication(
                new KeycloakAuthenticationOptions
                {
                    AuthServerUrl = "http://localhost:8080/",
                    Realm = "beeapps",
                    Resource = "stashed",
                    SslRequired = "none",
                    VerifyTokenAudience = false
                },
                options =>
                {
                    options.Events = new JwtBearerEvents
                    {
                        OnTokenValidated = async context =>
                        {
                            var userService = context.HttpContext.RequestServices.GetRequiredService<IUserService>();
                            var scopedOptions = context.HttpContext.RequestServices.GetRequiredService<AppOptions>();
                            var securityToken = (JwtSecurityToken)context.SecurityToken;

                            var tokenAudience = securityToken.Audiences.FirstOrDefault();
                            var username = context.Principal?.FindFirstValue("preferred_username");

                            if (tokenAudience == null)
                            {
                                context.Fail("Missing `aud` claim");
                                return;
                            }

                            if (username == null)
                            {
                                context.Fail("Missing `preferred_username` claim");
                                return;
                            }

                            if (tokenAudience != scopedOptions.Hostname)
                            {
                                context.Fail($"Invalid `aud` claim (expected {appOptions.Hostname}, was {tokenAudience})");
                                return;
                            }

                            await userService.AddUser(securityToken.Subject, username);
                        }
                    };
                    // If set to true (default), middleware auth can't find "sub" claim
                    // https://stackoverflow.com/a/68253821
                    options.MapInboundClaims = false;
                }
            );

            // Authorization
            builder.Services.AddAuthorization(
                o =>
                {
                    foreach (var permission in Enum.GetValues<PermissionType>())
                        o.AddPolicy(permission.ToString(), policy => { policy.Requirements.Add(new PermissionRequirement(permission)); });
                }
            );
        }

        // Custom services
        builder.Services.AddTransient<ICoreController>(_ => serviceProvider.GetRequiredService<ICoreController>());
        builder.Services.AddSingleton<ITaskQueue>(_ => serviceProvider.GetRequiredService<ITaskQueue>());
        builder.Services.AddTransient<IUserService, UserService>();
        builder.Services.AddSingleton<IAuthorizationHandler, PermissionHandler>();

        // Background Service
        builder.Services.AddHostedService<QueueBackgroundService>();

        _app = builder.Build();

        _app.MapHub<QueueHub>("/queue");

        if (appOptions.AuthEnabled)
            _app.MapControllers();
        else
            _app.MapControllers().AllowAnonymous();
    }

    public Task StartAsync(CancellationToken cancellationToken)
    {
        return _app.RunAsync();
    }

    public Task StopAsync(CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }
}
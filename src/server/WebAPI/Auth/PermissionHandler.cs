using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Stashed.Common.Contexts;
using Stashed.Common.Options;

namespace Stashed.WebAPI.Auth;

public class PermissionHandler(AppOptions appOptions) : AuthorizationHandler<PermissionRequirement>
{
    protected override async Task HandleRequirementAsync(AuthorizationHandlerContext context, PermissionRequirement requirement)
    {
        if (context.Resource is HttpContext httpContext)
        {
            if (appOptions.AuthEnabled == false)
            {
                context.Succeed(requirement);
                return;
            }

            var dbContext = httpContext.RequestServices.GetRequiredService<ApplicationDbContext>();

            var userId = httpContext.User.FindFirstValue("sub")!;

            var isAdmin = await dbContext.Users.FirstOrDefaultAsync(x => x.Id == userId && x.IsAdmin) != null;
            if (isAdmin)
            {
                context.Succeed(requirement);
                return;
            }

            var vaultId = httpContext.GetRouteData().Values["vaultId"] as string;

            var hasPermissions = await dbContext
                .UserRoles
                .Where(x => x.UserId == userId && x.VaultId == vaultId)
                .Select(x => x.Role)
                .AnyAsync(x => x.Permissions.Contains(requirement.Type));

            if (hasPermissions)
                context.Succeed(requirement);
        }
    }
}
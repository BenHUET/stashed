using Microsoft.AspNetCore.Authorization;
using Stashed.Common.Models.Permissions;

namespace Stashed.WebAPI.Auth;

public class PermissionRequirement(PermissionType type) : IAuthorizationRequirement
{
    public PermissionType Type => type;
}
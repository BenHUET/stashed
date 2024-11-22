using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Stashed.Common;
using Stashed.Common.Interfaces;
using Stashed.Common.Options;
using Stashed.WebAPI.Models;

namespace Stashed.WebAPI.Controllers;

[ApiController]
[Route("server")]
public class ServerController(ICoreController coreController, ILogger<ServerController> logger, AppOptions appOptions) : ControllerBase
{
    [HttpGet("manifest")]
    public async Task<IActionResult> GetManifest()
    {
        try
        {
            var manifest = new Manifest(
                Constants.AppVersion,
                appOptions.AuthEnabled
            );
            return Ok(manifest);
        }
        catch (Exception e)
        {
            logger.LogError(e, "Error getting manifest");
            return ResponseError.ServerError(e);
        }
    }


    [Authorize]
    [HttpGet("vaults")]
    public async Task<IActionResult> GetVaults()
    {
        try
        {
            var result = await coreController.GetVaults();
            return Ok(result);
        }
        catch (Exception e)
        {
            logger.LogError(e, "Error getting vaults");
            return ResponseError.ServerError(e);
        }
    }
}
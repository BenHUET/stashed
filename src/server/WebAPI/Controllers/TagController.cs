using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Stashed.Common.Interfaces;

namespace Stashed.WebAPI.Controllers;

[ApiController]
[Route("tag")]
public class TagController(ICoreController coreController, ILogger<MediaController> logger) : ControllerBase
{
}
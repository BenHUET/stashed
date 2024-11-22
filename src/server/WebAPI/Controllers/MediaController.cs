using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Stashed.Common.DTOs;
using Stashed.Common.Interfaces;
using Stashed.Common.Models;
using Stashed.WebAPI.Models;

namespace Stashed.WebAPI.Controllers;

[ApiController]
[Route("media")]
public class MediaController(ICoreController coreController, ILogger<MediaController> logger) : ControllerBase
{
    [Authorize(Policy = "ReadMedia")]
    [HttpGet("{vaultId}/{mediaId}")]
    public async Task<IActionResult> Get(string vaultId, string mediaId)
    {
        try
        {
            var media = await coreController.GetMedia(vaultId, mediaId);
            return Ok(media);
        }
        catch (Exception e)
        {
            logger.LogError(e, "Error getting media {MediaId} from vault {VaultId}", mediaId, vaultId);
            return Problem(e.Message);
        }
    }

    [HttpGet("{vaultId}/{mediaId}/{size:int}")]
    public async Task<IActionResult> GetThumbnail(string vaultId, string mediaId, int size)
    {
        try
        {
            var response = await coreController.GetThumbnail(vaultId, mediaId, size);
            return Ok(response);
        }
        catch (Exception e) when (e is DirectoryNotFoundException)
        {
            logger.LogWarning(e, "Error getting thumbnail for media {MediaId} from vault {VaultId} at size {ThumbnailSize}", mediaId, vaultId, size);
            return ResponseError.BadRequest("No thumbnail of this size found for this media.");
        }
        catch (Exception e)
        {
            logger.LogError(e, "Error getting thumbnail for media {MediaId} from vault {VaultId} at size {ThumbnailSize}", mediaId, vaultId, size);
            return ResponseError.ServerError(e);
        }
    }

    [HttpPost("{vaultId}")]
    public async Task<IActionResult> Import(string vaultId, [FromForm] MediaImportRequestDto dto)
    {
        try
        {
            using var stream = new MemoryStream();
            await dto.File.CopyToAsync(stream);

            var (mediaImportTask, thumbnailGenerateTasks) = await coreController.ImportMedia(vaultId, dto.File.FileName, stream.ToArray());

            var tasks = thumbnailGenerateTasks.Cast<ITrackedTask>().Concat(new[] { mediaImportTask });
            var response = new QueuedWorkResponseDto(tasks);

            return Ok(response);
        }
        catch (Exception e)
        {
            logger.LogError(e, "Error importing media {FileName} to vault {VaultId}", dto.File.FileName, vaultId);
            return Problem(e.Message);
        }
    }

    [HttpPost("search/{vaultId}")]
    public async Task<IActionResult> Search(string vaultId, [FromForm] SearchRequestDto dto)
    {
        try
        {
            var response = await coreController.Search(vaultId);
            return Ok(new { Medias = response });
        }
        catch (Exception e)
        {
            logger.LogError(e, "Error executing search query on vault {VaultId}", vaultId);
            return Problem(e.Message);
        }
    }
}
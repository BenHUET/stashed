using Microsoft.AspNetCore.JsonPatch;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using Stashed.Common.DTOs;
using Stashed.Common.Entities;
using Stashed.Common.Exceptions;
using Stashed.Common.Interfaces;
using Stashed.Common.Models;
using Stashed.WebAPI.Hubs;
using Stashed.WebAPI.Models;

namespace Stashed.WebAPI.Controllers;

[ApiController]
[Route("vault")]
public class VaultController(ICoreController coreController, IHubContext<QueueHub, IQueueClient> queueHubContext, ILogger<VaultController> logger)
    : ControllerBase
{
    [HttpPost]
    public async Task<IActionResult> Create(VaultCreateRequestDto requestDto)
    {
        try
        {
            dynamic vaultWorkOrder;
            if (requestDto.FileVaultCreateRequestDto != null)
                vaultWorkOrder = new FileVaultCreateRequest(
                    requestDto.FileVaultCreateRequestDto.Label,
                    requestDto.FileVaultCreateRequestDto.DatabaseDirectory
                );
            else
                throw new ArgumentException("Vault definition missing from request");

            dynamic storageWorkOrder;
            if (requestDto.LocalStorageCreateRequestDto != null)
                storageWorkOrder = new LocalStorageCreateRequest(
                    requestDto.LocalStorageCreateRequestDto.FilesDirectory
                );
            else
                throw new ArgumentException("Storage definition missing from request");

            var result = await coreController.CreateVaultWithStorage(vaultWorkOrder, storageWorkOrder);
            return Ok(result);
        }
        catch (Exception e) when (e is ArgumentException or UnauthorizedAccessException)
        {
            logger.LogWarning(e, "Error creating vault");
            return ResponseError.BadRequest(e);
        }
        catch (Exception e)
        {
            logger.LogError(e, "Error creating vault");
            return ResponseError.ServerError(e);
        }
    }

    [HttpPatch("{vaultId}")]
    public async Task<IActionResult> Update(string vaultId, [FromBody] JsonPatchDocument<Vault> patch)
    {
        try
        {
            var vault = await coreController.GetVault(vaultId);

            patch.ApplyTo(vault);

            if (vault is FileVault filevault)
                await coreController.UpdateVault(vaultId, filevault);
            else
                throw new NotImplementedException();

            return Ok();
        }
        catch (Exception e) when (e is ArgumentException or ProtectedFieldException)
        {
            logger.LogWarning(e, "Error updating vault {VaultId}", vaultId);
            return ResponseError.BadRequest(e);
        }
        catch (Exception e)
        {
            logger.LogError(e, "Error updating vault {VaultId}", vaultId);
            return ResponseError.ServerError(e);
        }
    }

    [HttpDelete("{vaultId}")]
    public async Task<IActionResult> Delete(string vaultId)
    {
        try
        {
            await coreController.DeleteVaultWithStorage(vaultId);
            await queueHubContext.Clients.Group(vaultId).ReceiveVaultDeletionNotification(vaultId);
            return Ok();
        }
        catch (Exception e)
        {
            logger.LogError(e, "Error deleting vault {VaultId}", vaultId);
            return ResponseError.ServerError(e.Message);
        }
    }
}
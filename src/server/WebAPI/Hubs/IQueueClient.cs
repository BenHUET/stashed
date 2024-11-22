using Stashed.Common.DTOs;

namespace Stashed.WebAPI.Hubs;

public interface IQueueClient
{
    Task ReceiveTask(TypedTrackedTaskDto trackedTask);
    Task ReceiveVaultDeletionNotification(string vaultId);
}
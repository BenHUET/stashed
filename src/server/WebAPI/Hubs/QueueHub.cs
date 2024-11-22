using Microsoft.AspNetCore.SignalR;
using Stashed.Common.DTOs;
using Stashed.Common.Interfaces;
using Stashed.Common.Models;
using Stashed.Common.Services;

namespace Stashed.WebAPI.Hubs;

public class QueueHub(ICoreController coreController, ITaskQueue taskQueue) : Hub<IQueueClient>
{
    private readonly HashSet<string> _groups = [];

    public async Task<bool> SubscribeToVault(string vaultId)
    {
        _groups.Add(vaultId);

        try
        {
            var found = await coreController.HasVault(vaultId);
            if (!found)
                throw new ArgumentException(vaultId);

            await Groups.AddToGroupAsync(Context.ConnectionId, vaultId);

            // On subscription to a vault, send all tasks enqueued related to this vault
            var tasks = (await taskQueue.GetAllTasks()).Where(t => t.VaultId != null && t.VaultId == vaultId);
            await SendTasks(Context.ConnectionId, tasks);

            return true;
        }
        catch
        {
            return false;
        }
    }

    public async Task<bool> UnsubscribeFromVault(string vaultId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, vaultId);
        return true;
    }

    public override async Task OnConnectedAsync()
    {
        // On connection, send all tasks currently enqueued and not related to a vault
        var tasks = (await taskQueue.GetAllTasks()).Where(t => t.VaultId == null);
        await SendTasks(Context.ConnectionId, tasks);
        await base.OnConnectedAsync();
    }

    public override Task OnDisconnectedAsync(Exception? exception)
    {
        foreach (var group in _groups)
            Groups.RemoveFromGroupAsync(Context.ConnectionId, group);

        return base.OnDisconnectedAsync(exception);
    }

    private async Task SendTasks(string connectionId, IEnumerable<ITrackedTask> tasks)
    {
        foreach (var task in tasks)
        {
            var dto = new TypedTrackedTaskDto(task);
            await Clients.Clients(connectionId).ReceiveTask(dto);
        }
    }
}
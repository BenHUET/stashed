using System.Threading.Channels;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Stashed.Common.DTOs;
using Stashed.Common.Models;
using Stashed.Common.Services;
using Stashed.WebAPI.Hubs;

namespace Stashed.WebAPI.Services;

public class QueueBackgroundService(
    ILogger<QueueBackgroundService> logger,
    ITaskQueue taskQueue,
    IHubContext<QueueHub, IQueueClient> queueHubContext)
    : BackgroundService
{
    private readonly Channel<ITrackedTask> _tasksQueue = Channel.CreateBounded<ITrackedTask>(new BoundedChannelOptions(int.MaxValue));

    protected override Task ExecuteAsync(CancellationToken cancellationToken)
    {
        taskQueue.OnEnqueuedTask += OnEnqueuedTask;

        return Process(cancellationToken);
    }

    private async Task Process(CancellationToken cancellationToken)
    {
        while (!cancellationToken.IsCancellationRequested)
            try
            {
                var trackedTask = await _tasksQueue.Reader.ReadAsync(cancellationToken);

                if (trackedTask.VaultId == null)
                    continue;

                var dto = new TypedTrackedTaskDto(trackedTask);

                await queueHubContext.Clients.Group(trackedTask.VaultId).ReceiveTask(dto);
                logger.LogInformation("Broadcasting {TrackedTaskId} {TrackedTaskSatus} ({TrackedTaskType})", trackedTask.Id, trackedTask.Status,
                    trackedTask.GetType());
            }
            catch (OperationCanceledException)
            {
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Error executing task");
            }
    }

    private async void OnEnqueuedTask(object? sender, ITrackedTask trackedTask)
    {
        trackedTask.OnStatusChanged += OnUpdatedTask;
        await _tasksQueue.Writer.WriteAsync(trackedTask);
    }

    private async void OnUpdatedTask(object? sender, ITrackedTask trackedTask)
    {
        if (trackedTask.FinishedAt != null)
            trackedTask.OnStatusChanged -= OnUpdatedTask;

        await _tasksQueue.Writer.WriteAsync(trackedTask);
    }
}
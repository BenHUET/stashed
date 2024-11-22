using System.Collections.Concurrent;
using Stashed.Common.Models;
using Stashed.Common.Services;

namespace Stashed.Core.Services;

public class TrackedTaskQueue : ITaskQueue
{
    private readonly ConcurrentQueue<ITrackedTask> _priorityQueue = new();
    private readonly ConcurrentQueue<ITrackedTask> _queue = new();

    public event EventHandler<ITrackedTask>? OnEnqueuedTask;

    public Task EnqueueTask(ITrackedTask item)
    {
        ArgumentNullException.ThrowIfNull(item);

        // If the task can be run right now, queue it in the normal queue
        if (item.DependsOn == null || item.DependsOn.FinishedAt != null)
        {
            _queue.Enqueue(item);
            item.Status = TrackedTaskStatus.Queued;
        }
        else
        {
            // If the task depends on another task, wait for it to finish then queue the depending task in the priority queue
            item.DependsOn.OnStatusChanged += (_, requisiteTask) =>
            {
                if (requisiteTask.FinishedAt != null) _priorityQueue.Enqueue(item);
            };
        }

        OnEnqueuedTask?.Invoke(this, item);

        return Task.CompletedTask;
    }

    public async Task<ITrackedTask> DequeueTask(CancellationToken cancellationToken)
    {
        while (true)
        {
            cancellationToken.ThrowIfCancellationRequested();

            if (_priorityQueue.TryDequeue(out var task) || _queue.TryDequeue(out task))
                return task;

            await Task.Delay(100, cancellationToken);
        }
    }

    public Task<IEnumerable<ITrackedTask>> GetAllTasks()
    {
        return Task.FromResult(_queue.ToList().Concat(_priorityQueue.ToList()));
    }
}
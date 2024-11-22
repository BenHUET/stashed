using Stashed.Common.Models;

namespace Stashed.Common.Services;

public interface ITaskQueue
{
    public event EventHandler<ITrackedTask>? OnEnqueuedTask;
    public Task EnqueueTask(ITrackedTask item);
    public Task<ITrackedTask> DequeueTask(CancellationToken cancellationToken);
    public Task<IEnumerable<ITrackedTask>> GetAllTasks();
}
namespace Stashed.Common.Models;

public interface ITrackedTask
{
    public string Id { get; }
    public string? VaultId { get; }
    public string? Error { get; }
    public TrackedTaskStatus Status { get; set; }
    public DateTime CreatedAt { get; }
    public DateTime? StartedAt { get; }
    public DateTime? FinishedAt { get; }
    public ITrackedTask? DependsOn { get; }

    public event EventHandler<ITrackedTask> OnStatusChanged;

    public Task Run(IServiceProvider serviceProvider);
}

public abstract class TrackedTask<TResult>(Func<IServiceProvider, Task<TResult>> task, string? vaultId = null, ITrackedTask? dependsOn = null)
    : ITrackedTask
{
    public TResult? Result { get; private set; }

    public string Id { get; } = Guid.NewGuid().ToString();
    public string? VaultId { get; } = vaultId;
    public string? Error { get; protected set; }
    public DateTime CreatedAt { get; } = DateTime.Now;
    public DateTime? StartedAt { get; private set; }
    public DateTime? FinishedAt { get; private set; }
    public TrackedTaskStatus Status { get; set; } = TrackedTaskStatus.Created;
    public ITrackedTask? DependsOn { get; } = dependsOn;

    public event EventHandler<ITrackedTask>? OnStatusChanged;

    public virtual async Task Run(IServiceProvider serviceProvider)
    {
        // If requisite task failed or was canceled, ignore this task
        if (DependsOn != null && DependsOn.Status != TrackedTaskStatus.Completed)
        {
            Status = TrackedTaskStatus.Ignored;
            FinishedAt = DateTime.Now;
            OnStatusChanged?.Invoke(this, this);
            return;
        }

        StartedAt = DateTime.Now;
        Status = TrackedTaskStatus.Running;

        OnStatusChanged?.Invoke(this, this);

        try
        {
            Result = await task(serviceProvider);
            Status = TrackedTaskStatus.Completed;
            FinishedAt = DateTime.Now;
        }
        catch
        {
            Status = TrackedTaskStatus.Failed;
            FinishedAt = DateTime.Now;
            throw;
        }
    }

    protected void NotifyStatusChanged()
    {
        OnStatusChanged?.Invoke(this, this);
    }
}
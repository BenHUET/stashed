using JetBrains.Annotations;
using Stashed.Common.Models;

namespace Stashed.Common.DTOs;

[PublicAPI]
public record QueuedWorkResponseDto(List<string> TasksIds)
{
    public QueuedWorkResponseDto(ITrackedTask trackedTask)
        : this([trackedTask.Id])
    {
    }

    public QueuedWorkResponseDto(IEnumerable<ITrackedTask> trackedTasks)
        : this(trackedTasks.Select(t => t.Id).ToList())
    {
    }
}
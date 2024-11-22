using JetBrains.Annotations;
using Stashed.Common.Models;

namespace Stashed.Common.DTOs;

[PublicAPI]
public record TypedTrackedTaskDto(
    string Type,
    TrackedTaskDto TrackedTaskDto,
    object? Result
)
{
    public TypedTrackedTaskDto(ITrackedTask trackedTask, object? result = null) : this(
        trackedTask.GetType().Name,
        new TrackedTaskDto(trackedTask),
        result)
    {
    }
}

[PublicAPI]
public record TrackedTaskDto(
    string Id,
    string? VaultId,
    string? Error,
    string? DependsOnId,
    DateTime CreatedAt,
    DateTime? StartedAt,
    DateTime? FinishedAt,
    TrackedTaskStatus Status
)
{
    public TrackedTaskDto(ITrackedTask trackedTask) : this(
        trackedTask.Id,
        trackedTask.VaultId,
        trackedTask.Error,
        trackedTask.DependsOn?.Id,
        trackedTask.CreatedAt,
        trackedTask.StartedAt,
        trackedTask.FinishedAt,
        trackedTask.Status)
    {
    }
}
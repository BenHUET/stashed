namespace Stashed.Common.Models;

public enum TrackedTaskStatus
{
    Created = 0,
    Queued = 1,
    Running = 2,
    Completed = 3,
    Failed = 4,
    Ignored = 5,
    Canceled = 6
}
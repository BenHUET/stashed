using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Stashed.Common.Services;

namespace Stashed.Core.Services;

public class QueueWorkerBackgroundService : BackgroundService
{
    private static int _workerCount;
    private readonly ILogger<QueueWorkerBackgroundService> _logger;
    private readonly IServiceScopeFactory _serviceScopeFactory;
    private readonly ITaskQueue _taskQueue;
    private readonly int _workerId;

    public QueueWorkerBackgroundService(ILogger<QueueWorkerBackgroundService> logger, IServiceScopeFactory serviceScopeFactory, ITaskQueue taskQueue)
    {
        _logger = logger;
        _serviceScopeFactory = serviceScopeFactory;
        _taskQueue = taskQueue;

        _workerId = _workerCount;
        _workerCount++;
    }

    protected override Task ExecuteAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation("{WorkerType}[{WorkerId}] running", nameof(QueueWorkerBackgroundService), _workerId);
        return Process(cancellationToken);
    }

    private async Task Process(CancellationToken cancellationToken)
    {
        while (!cancellationToken.IsCancellationRequested)
            try
            {
                var item = await _taskQueue.DequeueTask(cancellationToken);

                _logger.LogDebug("Running task {TaskType} {TaskId} on runner #{WorkerId}", item.GetType(), item.Id, _workerId);
                try
                {
                    await using var scope = _serviceScopeFactory.CreateAsyncScope();
                    await item.Run(scope.ServiceProvider);
                    _logger.LogDebug("Completed running task {TaskType} {TaskId} on runner #{WorkerId}", item.GetType(), item.Id, _workerId);
                }
                catch (Exception e)
                {
                    _logger.LogInformation(e, "Failed running task {TaskType} {TaskId} on runner #{WorkerId}", item.GetType(), item.Id, _workerId);
                }
            }
            catch (OperationCanceledException)
            {
                // Prevent throwing if cancellationToken was signaled
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error while processing task");
            }
    }
}
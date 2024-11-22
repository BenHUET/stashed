using Stashed.Common.Entities;

namespace Stashed.Common.Models;

public class GenerateThumbnailTrackedTask(Func<IServiceProvider, Task<Thumbnail>> task, string vaultId, ITrackedTask? dependsOn = null)
    : TrackedTask<Thumbnail>(task, vaultId, dependsOn)
{
    public override async Task Run(IServiceProvider serviceProvider)
    {
        try
        {
            await base.Run(serviceProvider);
        }
        catch (Exception e)
        {
            Error = e.Message;
            throw;
        }
        finally
        {
            NotifyStatusChanged();
        }
    }
}
using Stashed.Common.Entities;

namespace Stashed.Common.Models;

public class MediaImportTrackedTask(Func<IServiceProvider, Task<Media>> task, string vaultId, ITrackedTask? dependsOn = null)
    : TrackedTask<Media>(task, vaultId, dependsOn)
{
    public override async Task Run(IServiceProvider serviceProvider)
    {
        try
        {
            await base.Run(serviceProvider);
        }
        catch (NotSupportedException e)
        {
            Error = e.Message;
            throw;
        }
        catch
        {
            Error = "Unexpected error";
            throw;
        }
        finally
        {
            NotifyStatusChanged();
        }
    }
}
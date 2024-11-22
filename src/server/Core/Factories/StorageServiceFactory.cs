using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Stashed.Common.Contexts;
using Stashed.Common.Entities;
using Stashed.Core.Services;

namespace Stashed.Core.Factories;

public class StorageServiceFactory(ApplicationDbContext applicationDbContext, IServiceProvider serviceProvider) : IStorageServiceFactory
{
    public async Task<IStorageService> Get(string storageId)
    {
        var storage = await applicationDbContext.Storages.FirstOrDefaultAsync(s => s.Id == storageId);
        return storage switch
        {
            LocalStorage => serviceProvider.GetRequiredService<IStorageService<LocalStorage>>(),
            null => throw new ArgumentException("No storage corresponding to the provided id"),
            _ => throw new NotImplementedException()
        };
    }
}
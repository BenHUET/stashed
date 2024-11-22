using Microsoft.EntityFrameworkCore;
using Stashed.Common.Entities;
using Stashed.Core.Factories;

namespace Stashed.Core.Services.Search;

public class SearchService(IVaultDbContextFactory vaultDbContextFactory) : ISearchService
{
    public async Task<IEnumerable<Media>> SearchMedia(string vaultId)
    {
        var service = await vaultDbContextFactory.Get(vaultId);
        return await service.Media.ToListAsync();
    }
}
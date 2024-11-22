using Stashed.Common.Entities;

namespace Stashed.Core.Services.Search;

public interface ISearchService
{
    public Task<IEnumerable<Media>> SearchMedia(string vaultId);
}
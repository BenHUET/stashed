using Stashed.Core.Services;

namespace Stashed.Core.Factories;

public interface IStorageServiceFactory
{
    Task<IStorageService> Get(string storageId);
}
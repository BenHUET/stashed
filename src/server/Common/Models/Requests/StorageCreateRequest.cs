using Stashed.Common.Entities;

namespace Stashed.Common.Models;

// ReSharper disable once UnusedTypeParameter
public interface IStorageCreateRequest<TStorage> where TStorage : Storage;

public record LocalStorageCreateRequest(
    string? FilesDirectory
) : IStorageCreateRequest<LocalStorage>;
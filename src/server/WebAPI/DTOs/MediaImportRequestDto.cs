using JetBrains.Annotations;
using Microsoft.AspNetCore.Http;

namespace Stashed.Common.DTOs;

[PublicAPI]
public record MediaImportRequestDto(
    IFormFile File
);
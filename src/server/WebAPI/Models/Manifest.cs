namespace Stashed.WebAPI.Models;

public record Manifest(
    string Version,
    bool AuthEnabled
);
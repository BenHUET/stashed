using Microsoft.EntityFrameworkCore;

namespace Stashed.Core.Contexts;

public class SqliteVaultDbContext : VaultDbContext
{
    private readonly string _path = null!;

    public SqliteVaultDbContext()
    {
    }

    public SqliteVaultDbContext(string path)
    {
        _path = path;
    }

    protected override void OnConfiguring(DbContextOptionsBuilder options)
    {
        base.OnConfiguring(options);
        options.UseSqlite($"Data Source={_path}");
    }
}
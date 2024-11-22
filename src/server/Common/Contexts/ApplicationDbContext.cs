using Microsoft.EntityFrameworkCore;
using Stashed.Common.Entities;

namespace Stashed.Common.Contexts;

public class ApplicationDbContext : DbContext
{
    public virtual DbSet<User> Users => Set<User>();
    public virtual DbSet<UserRole> UserRoles => Set<UserRole>();
    public virtual DbSet<Role> Roles => Set<Role>();

    public virtual DbSet<Vault> Vaults => Set<Vault>();
    public virtual DbSet<FileVault> FileVaults => Set<FileVault>();

    public virtual DbSet<Storage> Storages => Set<Storage>();
    public virtual DbSet<LocalStorage> LocalStorages => Set<LocalStorage>();

    public virtual DbSet<Configuration> Configurations => Set<Configuration>();

    public ApplicationDbContext()
    {
    }

    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Vault>().UseTpcMappingStrategy();
        modelBuilder.Entity<Storage>().UseTpcMappingStrategy();

        base.OnModelCreating(modelBuilder);
    }
}
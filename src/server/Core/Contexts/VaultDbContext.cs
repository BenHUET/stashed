using Microsoft.EntityFrameworkCore;
using Stashed.Common.Entities;
using Image = Stashed.Common.Entities.Image;

namespace Stashed.Core.Contexts;

public abstract class VaultDbContext : DbContext
{
    public virtual DbSet<Media> Media => Set<Media>();
    public virtual DbSet<Image> Images => Set<Image>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Media>().UseTpcMappingStrategy();

        base.OnModelCreating(modelBuilder);
    }
}
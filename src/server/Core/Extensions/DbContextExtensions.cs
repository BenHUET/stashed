using Microsoft.EntityFrameworkCore;

namespace Stashed.Core.Extensions;

public static class DbContextExtensions
{
    public static async Task InsertOrUpdate<TEntity>(this DbContext context, TEntity entity) where TEntity : class
    {
        var alreadyExists = await context.Set<TEntity>().FirstOrDefaultAsync(e => e == entity);
        context.Entry(entity).State = alreadyExists != null ? EntityState.Modified : EntityState.Added;
    }
}
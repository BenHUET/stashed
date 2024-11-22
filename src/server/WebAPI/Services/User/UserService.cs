using Microsoft.EntityFrameworkCore;
using Stashed.Common.Contexts;
using Stashed.Common.Entities;

namespace Stashed.WebAPI.Services;

public class UserService(ApplicationDbContext applicationDbContext) : IUserService
{
    public async Task AddUser(string userId, string username, bool isAdmin = false)
    {
        if (!await applicationDbContext.Users.AnyAsync(u => u.Id == userId))
        {
            await applicationDbContext.Users.AddAsync(new User
            {
                Id = userId,
                Username = username,
                IsAdmin = false
            });

            await applicationDbContext.SaveChangesAsync();
        }
    }
}
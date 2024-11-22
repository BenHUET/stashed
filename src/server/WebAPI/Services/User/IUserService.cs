namespace Stashed.WebAPI.Services;

public interface IUserService
{
    public Task AddUser(string userId, string username, bool isAdmin = false);
}
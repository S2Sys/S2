using SmartWorkz.S2.Domain;

namespace SmartWorkz.S2.Infrastructure;

public class UserRepository : IUserRepository
{
    private readonly DatabaseConnection _db;

    public UserRepository(DatabaseConnection db)
    {
        _db = db ?? throw new ArgumentNullException(nameof(db));
    }

    public async Task<int> UpsertAsync(User user)
    {
        var parameters = new
        {
            UserID = user.UserID > 0 ? user.UserID : 0,
            Email = user.Email,
            PasswordHash = user.PasswordHash,
            FullName = user.FullName,
            Phone = user.Phone,
            Bio = user.Bio,
            ProfilePhotoUrl = user.ProfilePhotoUrl,
            IsActive = user.IsActive
        };

        var id = await _db.ExecuteScalarAsync<int>("uspUsersUpsert", parameters);
        return id > 0 ? id : user.UserID;
    }

    public async Task<User> GetByIdAsync(int id)
    {
        var result = await _db.QuerySingleOrDefaultAsync<User>("uspUsersGetById", new { UserID = id });
        return result ?? throw new KeyNotFoundException($"User {id} not found.");
    }

    public async Task<User> GetByEmailAsync(string email)
    {
        var result = await _db.QuerySingleOrDefaultAsync<User>("uspUsersGetByEmail", new { Email = email });
        return result ?? throw new KeyNotFoundException($"User with email '{email}' not found.");
    }

    public async Task<List<User>> GetAllAsync()
    {
        var results = await _db.QueryAsync<User>("uspUsersGet");
        return results.ToList();
    }

    public async Task DeleteAsync(int id)
    {
        await _db.ExecuteAsync("uspUsersDelete", new { UserID = id });
    }
}

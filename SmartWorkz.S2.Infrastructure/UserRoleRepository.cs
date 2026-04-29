using SmartWorkz.S2.Domain;

namespace SmartWorkz.S2.Infrastructure;

public class UserRoleRepository : IUserRoleRepository
{
    private readonly DatabaseConnection _db;

    public UserRoleRepository(DatabaseConnection db)
    {
        _db = db ?? throw new ArgumentNullException(nameof(db));
    }

    public async Task<int> AssignRoleAsync(int userId, int roleId)
    {
        var parameters = new { UserID = userId, RoleID = roleId };
        var id = await _db.ExecuteScalarAsync<int>("uspUserRolesAssignRole", parameters);
        return id;
    }

    public async Task<List<Role>> GetRolesByUserIdAsync(int userId)
    {
        var results = await _db.QueryAsync<Role>("uspUserRolesGetByUserId", new { UserID = userId });
        return results.ToList();
    }

    public async Task RemoveRoleAsync(int userId, int roleId)
    {
        await _db.ExecuteAsync("uspUserRolesRemoveRole", new { UserID = userId, RoleID = roleId });
    }
}

using SmartWorkz.S2.Domain;

namespace SmartWorkz.S2.Infrastructure;

public class RoleRepository : IRoleRepository
{
    private readonly DatabaseConnection _db;

    public RoleRepository(DatabaseConnection db)
    {
        _db = db ?? throw new ArgumentNullException(nameof(db));
    }

    public async Task<int> UpsertAsync(Role role)
    {
        var parameters = new
        {
            RoleID = role.RoleID > 0 ? role.RoleID : 0,
            RoleName = role.RoleName,
            Description = role.Description,
            IsActive = role.IsActive
        };

        var id = await _db.ExecuteScalarAsync<int>("uspRolesUpsert", parameters);
        return id > 0 ? id : role.RoleID;
    }

    public async Task<Role> GetByIdAsync(int id)
    {
        var result = await _db.QuerySingleOrDefaultAsync<Role>("uspRolesGetById", new { RoleID = id });
        return result ?? throw new KeyNotFoundException($"Role {id} not found.");
    }

    public async Task<List<Role>> GetAllAsync()
    {
        var results = await _db.QueryAsync<Role>("uspRolesGet");
        return results.ToList();
    }
}

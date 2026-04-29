using SmartWorkz.S2.Domain;

namespace SmartWorkz.S2.Infrastructure;

public class BranchRepository : IBranchRepository
{
    private readonly DatabaseConnection _db;

    public BranchRepository(DatabaseConnection db)
    {
        _db = db ?? throw new ArgumentNullException(nameof(db));
    }

    public async Task<int> UpsertAsync(Branch branch)
    {
        var parameters = new
        {
            BranchID = branch.BranchID > 0 ? branch.BranchID : 0,
            BranchName = branch.BranchName,
            Location = branch.Location,
            Address = branch.Address,
            Phone = branch.Phone,
            Email = branch.Email,
            IsHeadquarters = branch.IsHeadquarters
        };

        var id = await _db.ExecuteScalarAsync<int>("uspBranchUpsert", parameters);
        return id > 0 ? id : branch.BranchID;
    }

    public async Task<Branch> GetByIdAsync(int branchId)
    {
        var result = await _db.QuerySingleOrDefaultAsync<Branch>("uspBranchGetById", new { BranchID = branchId });
        return result ?? throw new KeyNotFoundException($"Branch {branchId} not found.");
    }

    public async Task<List<Branch>> GetAllAsync()
    {
        var results = await _db.QueryAsync<Branch>("uspBranchGet");
        return results.ToList();
    }

    public async Task<Branch?> GetHeadquartersAsync()
    {
        return await _db.QuerySingleOrDefaultAsync<Branch>("uspBranchGetHeadquarters");
    }

    public async Task DeleteAsync(int branchId)
    {
        await _db.ExecuteAsync("uspBranchDelete", new { BranchID = branchId });
    }
}

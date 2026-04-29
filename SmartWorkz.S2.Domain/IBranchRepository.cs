namespace SmartWorkz.S2.Domain;

public interface IBranchRepository
{
    Task<int> UpsertAsync(Branch branch);
    Task<Branch> GetByIdAsync(int branchId);
    Task<List<Branch>> GetAllAsync();
    Task<Branch?> GetHeadquartersAsync();
    Task DeleteAsync(int branchId);
}

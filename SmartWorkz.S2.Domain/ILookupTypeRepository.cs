namespace SmartWorkz.S2.Domain;

public interface ILookupTypeRepository
{
    Task<int> UpsertAsync(LookupType lookupType);
    Task<LookupType> GetByIdAsync(int lookupTypeId);
    Task<List<LookupType>> GetBycategoryAsync(string category);
    Task<List<LookupType>> GetAllAsync();
    Task DeleteAsync(int lookupTypeId);
}

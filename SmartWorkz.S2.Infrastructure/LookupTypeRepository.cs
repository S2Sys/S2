using SmartWorkz.S2.Domain;

namespace SmartWorkz.S2.Infrastructure;

public class LookupTypeRepository : ILookupTypeRepository
{
    private readonly DatabaseConnection _db;

    public LookupTypeRepository(DatabaseConnection db)
    {
        _db = db ?? throw new ArgumentNullException(nameof(db));
    }

    public async Task<int> UpsertAsync(LookupType lookupType)
    {
        var parameters = new
        {
            LookupTypeID = lookupType.LookupTypeID > 0 ? lookupType.LookupTypeID : 0,
            LookupCategory = lookupType.LookupCategory,
            LookupValue = lookupType.LookupValue,
            DisplayLabel = lookupType.DisplayLabel,
            ParentLookupTypeID = lookupType.ParentLookupTypeID,
            DisplayOrder = lookupType.DisplayOrder,
            IsActive = lookupType.IsActive
        };

        var id = await _db.ExecuteScalarAsync<int>("uspLookupTypeUpsert", parameters);
        return id > 0 ? id : lookupType.LookupTypeID;
    }

    public async Task<LookupType> GetByIdAsync(int lookupTypeId)
    {
        var result = await _db.QuerySingleOrDefaultAsync<LookupType>("uspLookupTypeGetById", new { LookupTypeID = lookupTypeId });
        return result ?? throw new KeyNotFoundException($"LookupType {lookupTypeId} not found.");
    }

    public async Task<List<LookupType>> GetBycategoryAsync(string category)
    {
        var results = await _db.QueryAsync<LookupType>("uspLookupTypeGetByCategory", new { LookupCategory = category });
        return results.ToList();
    }

    public async Task<List<LookupType>> GetAllAsync()
    {
        var results = await _db.QueryAsync<LookupType>("uspLookupTypeGet");
        return results.ToList();
    }

    public async Task DeleteAsync(int lookupTypeId)
    {
        await _db.ExecuteAsync("uspLookupTypeDelete", new { LookupTypeID = lookupTypeId });
    }
}

using SmartWorkz.S2.Domain;

namespace SmartWorkz.S2.Infrastructure;

public class SettingsRepository : ISettingsRepository
{
    private readonly DatabaseConnection _db;

    public SettingsRepository(DatabaseConnection db)
    {
        _db = db ?? throw new ArgumentNullException(nameof(db));
    }

    public async Task<int> UpsertAsync(Settings settings)
    {
        var parameters = new
        {
            SettingID = settings.SettingID > 0 ? settings.SettingID : 0,
            SettingKey = settings.SettingKey,
            SettingValue = settings.SettingValue
        };

        var id = await _db.ExecuteScalarAsync<int>("uspSettingsUpsert", parameters);
        return id > 0 ? id : settings.SettingID;
    }

    public async Task<Settings> GetByKeyAsync(string key)
    {
        var result = await _db.QuerySingleOrDefaultAsync<Settings>("uspSettingsGetByKey", new { SettingKey = key });
        return result ?? throw new KeyNotFoundException($"Setting '{key}' not found.");
    }

    public async Task<List<Settings>> GetAllAsync()
    {
        var results = await _db.QueryAsync<Settings>("uspSettingsGet");
        return results.ToList();
    }
}

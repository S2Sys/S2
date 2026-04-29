using System.Data;
using Dapper;
using SmartWorkz.S2.Domain;

namespace SmartWorkz.S2.Infrastructure;

public class DatabaseConnection
{
    private readonly IDbConnectionFactory _factory;

    public DatabaseConnection(IDbConnectionFactory factory)
    {
        _factory = factory ?? throw new ArgumentNullException(nameof(factory));
    }

    public async Task<IEnumerable<T>> QueryAsync<T>(string sprocName, object? parameters = null)
    {
        using var connection = _factory.CreateConnection();
        return await connection.QueryAsync<T>(sprocName, parameters, commandType: CommandType.StoredProcedure);
    }

    public async Task<T?> QuerySingleOrDefaultAsync<T>(string sprocName, object? parameters = null)
    {
        using var connection = _factory.CreateConnection();
        return await connection.QuerySingleOrDefaultAsync<T>(sprocName, parameters, commandType: CommandType.StoredProcedure);
    }

    public async Task<T?> ExecuteScalarAsync<T>(string sprocName, object? parameters = null)
    {
        using var connection = _factory.CreateConnection();
        return await connection.ExecuteScalarAsync<T>(sprocName, parameters, commandType: CommandType.StoredProcedure);
    }

    public async Task<int> ExecuteAsync(string sprocName, object? parameters = null)
    {
        using var connection = _factory.CreateConnection();
        return await connection.ExecuteAsync(sprocName, parameters, commandType: CommandType.StoredProcedure);
    }
}

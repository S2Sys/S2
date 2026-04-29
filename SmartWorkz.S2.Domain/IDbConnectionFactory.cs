using System.Data;

namespace SmartWorkz.S2.Domain;

public interface IDbConnectionFactory
{
    IDbConnection CreateConnection();
}

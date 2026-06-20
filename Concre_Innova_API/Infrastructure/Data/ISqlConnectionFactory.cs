using Microsoft.Data.SqlClient;

namespace Concre_Innova_API.Infrastructure.Data
{
    public interface ISqlConnectionFactory
    {
        bool HasConnectionString { get; }
        SqlConnection CreateConnection();
    }
}

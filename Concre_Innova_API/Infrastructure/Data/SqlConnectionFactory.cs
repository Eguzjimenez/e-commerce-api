using Concre_Innova_API.Shared.Constants;
using Microsoft.Data.SqlClient;

namespace Concre_Innova_API.Infrastructure.Data
{
    public class SqlConnectionFactory : ISqlConnectionFactory
    {
        private readonly string _connectionString;

        public SqlConnectionFactory(IConfiguration configuration)
        {
            _connectionString =
                configuration.GetConnectionString(ConfigurationKeys.DefaultConnection) ??
                string.Empty;
        }

        public bool HasConnectionString => !string.IsNullOrWhiteSpace(_connectionString);

        public SqlConnection CreateConnection()
        {
            return new SqlConnection(_connectionString);
        }
    }
}

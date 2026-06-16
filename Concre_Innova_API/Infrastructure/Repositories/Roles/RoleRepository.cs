using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Infrastructure.Data;
using Concre_Innova_API.Application.DTOs.Responses;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Roles
{
    public class RoleRepository : IRoleRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public RoleRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<IEnumerable<RoleResponseDto>> GetRolesAsync()
        {
            var list = new List<RoleResponseDto>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerRoles", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new RoleResponseDto
                {
                    IdRol = reader.GetInt32(reader.GetOrdinal("IdRol")),
                    NombreRol = reader.GetString(reader.GetOrdinal("NombreRol"))
                });
            }

            return list;
        }
    }
}

using Concre_Innova_API.Models.DTOs.Responses;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Repositories.Roles
{
    public class RoleRepository : IRoleRepository
    {
        private readonly string _connectionString;

        public RoleRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection") ?? string.Empty;
        }

        public async Task<IEnumerable<RoleResponseDto>> GetRolesAsync()
        {
            var list = new List<RoleResponseDto>();

            await using var conn = new SqlConnection(_connectionString);
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

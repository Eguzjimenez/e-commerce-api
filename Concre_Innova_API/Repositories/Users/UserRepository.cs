using Concre_Innova_API.Models.DTOs.Responses;
using Concre_Innova_API.Models.DTOs.Requests;
using Concre_Innova_API.Models.Entities;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Repositories.Users
{
    public class UserRepository : IUserRepository
    {
        private readonly string _connectionString;

        public UserRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection") ?? string.Empty;
        }

        public async Task<IEnumerable<UserResponseDto>> GetUsersAsync()
        {
            var list = new List<UserResponseDto>();

            await using var conn = new SqlConnection(_connectionString);
            await using var cmd = new SqlCommand("SP_ObtenerUsuarios", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new UserResponseDto
                {
                    IdUsuario = reader.GetInt32(reader.GetOrdinal("IdUsuario")),
                    Nombre = reader.GetString(reader.GetOrdinal("Nombre")),
                    Apellido = reader.GetString(reader.GetOrdinal("Apellido")),
                    Correo = reader.GetString(reader.GetOrdinal("Correo")),
                    Telefono = reader.IsDBNull(reader.GetOrdinal("Telefono")) ? string.Empty : reader.GetString(reader.GetOrdinal("Telefono")),
                    IdRol = reader.GetInt32(reader.GetOrdinal("IdRol"))
                });
            }

            return list;
        }

        public async Task<User> LoginAsync(string correo, string contrasena)
        {
            var result = new User();

            await using var conn = new SqlConnection(_connectionString);
            await using var cmd = new SqlCommand("SP_Login", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@Correo", correo);
            cmd.Parameters.AddWithValue("@Contrasena", contrasena);

            await conn.OpenAsync();

            try
            {
                await using var reader = await cmd.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    result.Codigo = reader.GetInt32(reader.GetOrdinal("Codigo"));
                    result.Mensaje = reader.GetString(reader.GetOrdinal("Mensaje"));

                    if (result.Codigo == 1)
                    {
                        result.IdUsuario = reader.GetInt32(reader.GetOrdinal("IdUsuario"));
                        result.Nombre = reader.GetString(reader.GetOrdinal("Nombre"));
                        result.Apellido = reader.GetString(reader.GetOrdinal("Apellido"));
                        result.Correo = reader.GetString(reader.GetOrdinal("Correo"));
                        result.Telefono = reader.GetString(reader.GetOrdinal("Telefono"));
                        result.IdRol = reader.GetInt32(reader.GetOrdinal("IdRol"));
                        result.NombreRol = reader.GetString(reader.GetOrdinal("NombreRol"));
                    }
                }
            }
            catch (Exception ex)
            {
                result.Codigo = -1;
                result.Mensaje = ex.Message;
            }

            return result;
        }
    }
}

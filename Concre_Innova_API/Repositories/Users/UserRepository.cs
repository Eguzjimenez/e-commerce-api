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

        public async Task<Models.Entities.User> UpdateUserAsync(Models.Entities.User user)
        {
            var result = new Models.Entities.User();

            await using var conn = new SqlConnection(_connectionString);
            await using var cmd = new SqlCommand("SP_ActualizarUsuario", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@IdUsuario", user.IdUsuario ?? 0);
            cmd.Parameters.AddWithValue("@Nombre", user.Nombre ?? string.Empty);
            cmd.Parameters.AddWithValue("@Apellido", user.Apellido ?? string.Empty);
            cmd.Parameters.AddWithValue("@Correo", user.Correo ?? string.Empty);
            // If Contrasena is null or empty, pass DBNull to allow SP to skip password update
            if (string.IsNullOrEmpty(user.Contrasena))
                cmd.Parameters.AddWithValue("@Contrasena", DBNull.Value);
            else
                cmd.Parameters.AddWithValue("@Contrasena", user.Contrasena);

            cmd.Parameters.AddWithValue("@Telefono", user.Telefono ?? string.Empty);
            cmd.Parameters.AddWithValue("@IdRol", user.IdRol ?? 0);

            await conn.OpenAsync();

            try
            {
                await using var reader = await cmd.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    result.Codigo = reader.GetInt32(reader.GetOrdinal("Codigo"));
                    result.Mensaje = reader.GetString(reader.GetOrdinal("Mensaje"));
                }
            }
            catch (Exception ex)
            {
                result.Codigo = -1;
                result.Mensaje = ex.Message;
            }

            return result;
        }

        public async Task<Models.Entities.User> InsertUserAsync(Models.Entities.User user)
        {
            var result = new Models.Entities.User();

            await using var conn = new SqlConnection(_connectionString);
            await using var cmd = new SqlCommand("SP_InsertarUsuario", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@Nombre", user.Nombre ?? string.Empty);
            cmd.Parameters.AddWithValue("@Apellido", user.Apellido ?? string.Empty);
            cmd.Parameters.AddWithValue("@Correo", user.Correo ?? string.Empty);
            cmd.Parameters.AddWithValue("@Contrasena", user.Contrasena ?? string.Empty);
            cmd.Parameters.AddWithValue("@Telefono", user.Telefono ?? string.Empty);
            cmd.Parameters.AddWithValue("@IdRol", user.IdRol ?? 0);

            await conn.OpenAsync();

            try
            {
                await using var reader = await cmd.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    result.Codigo = reader.GetInt32(reader.GetOrdinal("Codigo"));
                    result.Mensaje = reader.GetString(reader.GetOrdinal("Mensaje"));

                    if (result.Codigo == 1 && !reader.IsDBNull(reader.GetOrdinal("IdUsuario")))
                        result.IdUsuario = reader.GetInt32(reader.GetOrdinal("IdUsuario"));
                }
            }
            catch (Exception ex)
            {
                result.Codigo = -1;
                result.Mensaje = ex.Message;
            }

            return result;
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

        public async Task<UserLogin> LoginAsync(string correo, string contrasena)
        {
            var result = new UserLogin();

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
                        if (!reader.IsDBNull(reader.GetOrdinal("IdUsuario")))
                            result.IdUsuario = reader.GetInt32(reader.GetOrdinal("IdUsuario"));

                        if (!reader.IsDBNull(reader.GetOrdinal("IdRol")))
                            result.IdRol = reader.GetInt32(reader.GetOrdinal("IdRol"));
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

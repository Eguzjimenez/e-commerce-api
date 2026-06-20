using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Infrastructure.Data;
using Concre_Innova_API.Domain.Entities;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Users
{
    public class UserRepository : IUserRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public UserRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<User> UpdateUserAsync(User user)
        {
            var result = new User();

            await using var conn = _connectionFactory.CreateConnection();
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

        public async Task<User> InsertUserAsync(User user)
        {
            var result = new User();

            await using var conn = _connectionFactory.CreateConnection();
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

            await using var conn = _connectionFactory.CreateConnection();
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

        public async Task<UserDetailResponseDto?> GetUserByIdAsync(int idUsuario)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand(@"
                SELECT
                    u.IdUsuario,
                    u.Nombre,
                    u.Apellido,
                    u.Correo,
                    u.Telefono,
                    u.Estado,
                    u.FechaRegistro,
                    u.IdRol,
                    r.NombreRol
                FROM Usuarios u
                INNER JOIN Roles r ON r.IdRol = u.IdRol
                WHERE u.IdUsuario = @IdUsuario;", conn)
            {
                CommandType = CommandType.Text
            };

            cmd.Parameters.AddWithValue("@IdUsuario", idUsuario);

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync())
                return null;

            return new UserDetailResponseDto
            {
                IdUsuario = reader.GetInt32(reader.GetOrdinal("IdUsuario")),
                Nombre = reader.GetString(reader.GetOrdinal("Nombre")),
                Apellido = reader.GetString(reader.GetOrdinal("Apellido")),
                Correo = reader.GetString(reader.GetOrdinal("Correo")),
                Telefono = reader.IsDBNull(reader.GetOrdinal("Telefono")) ? string.Empty : reader.GetString(reader.GetOrdinal("Telefono")),
                Estado = reader.IsDBNull(reader.GetOrdinal("Estado")) ? string.Empty : reader.GetString(reader.GetOrdinal("Estado")),
                FechaRegistro = reader.IsDBNull(reader.GetOrdinal("FechaRegistro")) ? null : reader.GetDateTime(reader.GetOrdinal("FechaRegistro")),
                IdRol = reader.GetInt32(reader.GetOrdinal("IdRol")),
                NombreRol = reader.GetString(reader.GetOrdinal("NombreRol"))
            };
        }

        public async Task<User> DeactivateUserAsync(int idUsuario)
        {
            var result = new User();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_DesactivarUsuario", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@IdUsuario", idUsuario);

            await conn.OpenAsync();

            try
            {
                await using var reader = await cmd.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    result.Codigo = reader.GetInt32(reader.GetOrdinal("Codigo"));
                    result.Mensaje = reader.GetString(reader.GetOrdinal("Mensaje"));
                    result.IdUsuario = idUsuario;
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

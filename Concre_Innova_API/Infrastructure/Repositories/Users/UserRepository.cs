using Concre_Innova_API.Application.DTOs.Requests;
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

        public async Task<UpdateUserInfoResponseDto> UpdateUserInfoAsync(UpdateUserInfoRequest request)
        {
            var result = new UpdateUserInfoResponseDto();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ActualizarInformacionUsuario", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@IdUsuario", request.IdUsuario);
            cmd.Parameters.AddWithValue("@Nombre", request.Nombre ?? string.Empty);
            cmd.Parameters.AddWithValue("@Apellido", request.Apellido ?? string.Empty);
            cmd.Parameters.AddWithValue("@Correo", request.Correo ?? string.Empty);
            cmd.Parameters.AddWithValue("@Telefono", request.Telefono ?? string.Empty);
            cmd.Parameters.AddWithValue("@Direccion", request.Direccion ?? string.Empty);

            // Si Contrasena es null o vacío, se pasa DBNull para mantener la contraseña actual
            if (string.IsNullOrEmpty(request.Contrasena))
                cmd.Parameters.AddWithValue("@Contrasena", DBNull.Value);
            else
                cmd.Parameters.AddWithValue("@Contrasena", request.Contrasena);

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
                    IdRol = reader.GetInt32(reader.GetOrdinal("IdRol")),
                    NombreRol = reader.IsDBNull(reader.GetOrdinal("NombreRol"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("NombreRol"))
                });
            }

            return list;
        }

        public async Task<PaginatedResponseDto<UserResponseDto>> GetUsersPaginadosAsync(
            PaginationQuery pagination,
            string? busqueda,
            int? idRol)
        {
            var list = new List<UserResponseDto>();
            var totalItems = 0;
            var normalizedSearch = NormalizeText(busqueda);
            var normalizedRoleId = idRol.HasValue && idRol.Value > 0 ? idRol.Value : (int?)null;

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand(
                """
                SELECT
                    u.IdUsuario,
                    u.Nombre,
                    u.Apellido,
                    u.Correo,
                    u.Telefono,
                    u.IdRol,
                    ISNULL(r.NombreRol, '') AS NombreRol,
                    COUNT(1) OVER() AS TotalItems
                FROM Usuarios u
                LEFT JOIN Roles r ON r.IdRol = u.IdRol
                WHERE (@Busqueda IS NULL
                        OR u.Nombre COLLATE Latin1_General_CI_AI LIKE @BusquedaPattern ESCAPE '\'
                        OR u.Apellido COLLATE Latin1_General_CI_AI LIKE @BusquedaPattern ESCAPE '\'
                        OR u.Correo COLLATE Latin1_General_CI_AI LIKE @BusquedaPattern ESCAPE '\'
                        OR ISNULL(u.Telefono, '') COLLATE Latin1_General_CI_AI LIKE @BusquedaPattern ESCAPE '\')
                    AND (@IdRol IS NULL OR u.IdRol = @IdRol)
                ORDER BY u.IdUsuario DESC
                OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
                """,
                conn)
            {
                CommandType = CommandType.Text
            };

            AddNullableTextParameter(cmd, "@Busqueda", normalizedSearch);
            AddNullableTextParameter(
                cmd,
                "@BusquedaPattern",
                normalizedSearch is null ? null : $"%{EscapeLikeValue(normalizedSearch)}%",
                -1);
            cmd.Parameters.Add("@IdRol", SqlDbType.Int).Value =
                normalizedRoleId.HasValue ? normalizedRoleId.Value : DBNull.Value;
            cmd.Parameters.Add("@Offset", SqlDbType.Int).Value = pagination.Offset;
            cmd.Parameters.Add("@PageSize", SqlDbType.Int).Value = pagination.PageSize;

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapUser(reader));
                totalItems = reader.GetInt32(reader.GetOrdinal("TotalItems"));
            }

            return new PaginatedResponseDto<UserResponseDto>
            {
                Items = list,
                TotalItems = totalItems,
                PageNumber = pagination.PageNumber,
                PageSize = pagination.PageSize
            };
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

        public async Task<UserInfoResponseDto?> GetUserInfoAsync(int idUsuario)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerInformacionUsuario", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@IdUsuario", idUsuario);

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync())
                return null;

            return new UserInfoResponseDto
            {
                IdUsuario = reader.GetInt32(reader.GetOrdinal("IdUsuario")),
                Nombre = reader.GetString(reader.GetOrdinal("Nombre")),
                Apellido = reader.GetString(reader.GetOrdinal("Apellido")),
                Correo = reader.GetString(reader.GetOrdinal("Correo")),
                Telefono = reader.IsDBNull(reader.GetOrdinal("Telefono")) ? null : reader.GetString(reader.GetOrdinal("Telefono")),
                Estado = reader.IsDBNull(reader.GetOrdinal("Estado")) ? null : reader.GetString(reader.GetOrdinal("Estado")),
                FechaRegistro = reader.IsDBNull(reader.GetOrdinal("FechaRegistro")) ? null : reader.GetDateTime(reader.GetOrdinal("FechaRegistro")),
                IdRol = reader.GetInt32(reader.GetOrdinal("IdRol")),
                NombreRol = reader.IsDBNull(reader.GetOrdinal("NombreRol")) ? null : reader.GetString(reader.GetOrdinal("NombreRol")),
                IdCliente = reader.IsDBNull(reader.GetOrdinal("IdCliente")) ? null : reader.GetInt32(reader.GetOrdinal("IdCliente")),
                Direccion = reader.IsDBNull(reader.GetOrdinal("Direccion")) ? null : reader.GetString(reader.GetOrdinal("Direccion")),
                EstadoCliente = reader.IsDBNull(reader.GetOrdinal("EstadoCliente")) ? null : reader.GetString(reader.GetOrdinal("EstadoCliente")),
                FechaRegistroCliente = reader.IsDBNull(reader.GetOrdinal("FechaRegistroCliente")) ? null : reader.GetDateTime(reader.GetOrdinal("FechaRegistroCliente"))
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

        private static UserResponseDto MapUser(SqlDataReader reader)
        {
            return new UserResponseDto
            {
                IdUsuario = reader.GetInt32(reader.GetOrdinal("IdUsuario")),
                Nombre = reader.GetString(reader.GetOrdinal("Nombre")),
                Apellido = reader.GetString(reader.GetOrdinal("Apellido")),
                Correo = reader.GetString(reader.GetOrdinal("Correo")),
                Telefono = reader.IsDBNull(reader.GetOrdinal("Telefono")) ? string.Empty : reader.GetString(reader.GetOrdinal("Telefono")),
                IdRol = reader.GetInt32(reader.GetOrdinal("IdRol")),
                NombreRol = reader.IsDBNull(reader.GetOrdinal("NombreRol")) ? string.Empty : reader.GetString(reader.GetOrdinal("NombreRol"))
            };
        }

        private static void AddNullableTextParameter(
            SqlCommand cmd,
            string parameterName,
            string? value,
            int size = 255)
        {
            cmd.Parameters.Add(parameterName, SqlDbType.NVarChar, size).Value =
                value is null ? DBNull.Value : value;
        }

        private static string? NormalizeText(string? value)
        {
            return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
        }

        private static string EscapeLikeValue(string value)
        {
            return value
                .Replace(@"\", @"\\")
                .Replace("%", @"\%")
                .Replace("_", @"\_")
                .Replace("[", @"\[");
        }
    }
}

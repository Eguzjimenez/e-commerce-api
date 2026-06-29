using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Domain.Constants;
using Concre_Innova_API.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Permissions
{
    public class PermissionRepository : IPermissionRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public PermissionRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<bool> RoleHasPermissionAsync(int roleId, string permissionCode)
        {
            try
            {
                await using var conn = _connectionFactory.CreateConnection();
                await using var cmd = new SqlCommand(
                    """
                    SELECT COUNT(1)
                    FROM RolPermisos rp
                    INNER JOIN Permisos p ON p.IdPermiso = rp.IdPermiso
                    WHERE rp.IdRol = @IdRol
                        AND p.Codigo = @Codigo
                        AND p.Estado = 'Activo';
                    """,
                    conn)
                {
                    CommandType = CommandType.Text
                };

                cmd.Parameters.Add("@IdRol", SqlDbType.Int).Value = roleId;
                cmd.Parameters.Add("@Codigo", SqlDbType.VarChar, 120).Value = permissionCode;

                await conn.OpenAsync();
                var count = Convert.ToInt32(await cmd.ExecuteScalarAsync());
                return count > 0;
            }
            catch (SqlException ex) when (ex.Number is 207 or 208)
            {
                return roleId == AppRoles.Administrador;
            }
        }

        public async Task<IEnumerable<RolePermissionsResponseDto>> GetRolePermissionsAsync()
        {
            var roles = new Dictionary<int, RolePermissionsResponseDto>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = CreateRolePermissionsCommand(conn, null);

            await conn.OpenAsync();
            await using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                var roleId = reader.GetInt32(reader.GetOrdinal("IdRol"));

                if (!roles.TryGetValue(roleId, out var role))
                {
                    role = new RolePermissionsResponseDto
                    {
                        IdRol = roleId,
                        NombreRol = reader.GetString(reader.GetOrdinal("NombreRol")),
                        Permisos = new List<PermissionResponseDto>()
                    };

                    roles.Add(roleId, role);
                }

                ((List<PermissionResponseDto>)role.Permisos).Add(MapPermission(reader));
            }

            return roles.Values;
        }

        public async Task<RolePermissionsResponseDto?> GetRolePermissionsAsync(int roleId)
        {
            var roles = await GetRolePermissionsAsync();
            return roles.FirstOrDefault(role => role.IdRol == roleId);
        }

        public async Task<OperacionResponseDto> UpdateRolePermissionsAsync(UpdateRolePermissionsRequest request)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await conn.OpenAsync();
            await using var transaction = await conn.BeginTransactionAsync();

            try
            {
                await using var deleteCommand = new SqlCommand(
                    "DELETE FROM RolPermisos WHERE IdRol = @IdRol;",
                    conn,
                    (SqlTransaction)transaction);
                deleteCommand.Parameters.Add("@IdRol", SqlDbType.Int).Value = request.IdRol;
                await deleteCommand.ExecuteNonQueryAsync();

                foreach (var permissionId in request.IdPermisos.Distinct())
                {
                    await using var insertCommand = new SqlCommand(
                        """
                        INSERT INTO RolPermisos (IdRol, IdPermiso)
                        SELECT @IdRol, @IdPermiso
                        WHERE EXISTS (SELECT 1 FROM Roles WHERE IdRol = @IdRol)
                            AND EXISTS (SELECT 1 FROM Permisos WHERE IdPermiso = @IdPermiso);
                        """,
                        conn,
                        (SqlTransaction)transaction);

                    insertCommand.Parameters.Add("@IdRol", SqlDbType.Int).Value = request.IdRol;
                    insertCommand.Parameters.Add("@IdPermiso", SqlDbType.Int).Value = permissionId;
                    await insertCommand.ExecuteNonQueryAsync();
                }

                await transaction.CommitAsync();

                return new OperacionResponseDto
                {
                    Codigo = 1,
                    Mensaje = "Permisos actualizados correctamente."
                };
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        private static SqlCommand CreateRolePermissionsCommand(SqlConnection conn, int? roleId)
        {
            var cmd = new SqlCommand(
                """
                SELECT
                    r.IdRol,
                    r.NombreRol,
                    p.IdPermiso,
                    p.Codigo,
                    p.Nombre,
                    p.Modulo,
                    ISNULL(p.Descripcion, '') AS Descripcion,
                    CAST(CASE WHEN rp.IdPermiso IS NULL THEN 0 ELSE 1 END AS BIT) AS Asignado
                FROM Roles r
                CROSS JOIN Permisos p
                LEFT JOIN RolPermisos rp ON rp.IdRol = r.IdRol AND rp.IdPermiso = p.IdPermiso
                WHERE p.Estado = 'Activo'
                    AND (@IdRol IS NULL OR r.IdRol = @IdRol)
                ORDER BY r.IdRol, p.Modulo, p.Nombre;
                """,
                conn)
            {
                CommandType = CommandType.Text
            };

            cmd.Parameters.Add("@IdRol", SqlDbType.Int).Value = roleId.HasValue
                ? roleId.Value
                : DBNull.Value;

            return cmd;
        }

        private static PermissionResponseDto MapPermission(SqlDataReader reader)
        {
            return new PermissionResponseDto
            {
                IdPermiso = reader.GetInt32(reader.GetOrdinal("IdPermiso")),
                Codigo = reader.GetString(reader.GetOrdinal("Codigo")),
                Nombre = reader.GetString(reader.GetOrdinal("Nombre")),
                Modulo = reader.GetString(reader.GetOrdinal("Modulo")),
                Descripcion = reader.GetString(reader.GetOrdinal("Descripcion")),
                Asignado = reader.GetBoolean(reader.GetOrdinal("Asignado"))
            };
        }
    }
}

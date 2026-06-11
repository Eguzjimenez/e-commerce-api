using Concre_Innova_API.Services.Security;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Services.Audit
{
    public class AuditService : IAuditService
    {
        private readonly string _connectionString;
        private readonly ILogger<AuditService> _logger;

        public AuditService(IConfiguration configuration, ILogger<AuditService> logger)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection") ?? string.Empty;
            _logger = logger;
        }

        public async Task RecordAsync(RequestUserContext userContext, string module, string operation, string description)
        {
            if (!userContext.UserId.HasValue || string.IsNullOrWhiteSpace(_connectionString))
                return;

            try
            {
                await using var conn = new SqlConnection(_connectionString);
                await using var cmd = new SqlCommand(@"
                    INSERT INTO Bitacora
                        (IdUsuario, TablaAfectada, Operacion, Descripcion, FechaHora, IpUsuario)
                    VALUES
                        (@IdUsuario, @TablaAfectada, @Operacion, @Descripcion, GETDATE(), @IpUsuario);", conn)
                {
                    CommandType = CommandType.Text
                };

                cmd.Parameters.AddWithValue("@IdUsuario", userContext.UserId.Value);
                cmd.Parameters.AddWithValue("@TablaAfectada", Truncate(module, 100));
                cmd.Parameters.AddWithValue("@Operacion", Truncate(operation, 20));
                cmd.Parameters.AddWithValue("@Descripcion", Truncate(
                    $"{description} | Rol: {userContext.RoleName} ({userContext.RoleId})",
                    500));
                cmd.Parameters.AddWithValue("@IpUsuario", Truncate(userContext.IpAddress, 50));

                await conn.OpenAsync();
                await cmd.ExecuteNonQueryAsync();
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "No se pudo registrar la auditoria para el modulo {Module}.", module);
            }
        }

        private static string Truncate(string value, int maxLength)
        {
            if (string.IsNullOrEmpty(value))
                return string.Empty;

            return value.Length <= maxLength ? value : value[..maxLength];
        }
    }
}

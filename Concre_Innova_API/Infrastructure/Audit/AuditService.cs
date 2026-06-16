using Concre_Innova_API.Infrastructure.Data;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Security;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Audit
{
    public class AuditService : IAuditService
    {
        private readonly ISqlConnectionFactory _connectionFactory;
        private readonly ILogger<AuditService> _logger;

        public AuditService(ISqlConnectionFactory connectionFactory, ILogger<AuditService> logger)
        {
            _connectionFactory = connectionFactory;
            _logger = logger;
        }

        public async Task RecordAsync(RequestUserContext userContext, string module, string operation, string description)
        {
            if (!userContext.UserId.HasValue || !_connectionFactory.HasConnectionString)
                return;

            try
            {
                await using var conn = _connectionFactory.CreateConnection();
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

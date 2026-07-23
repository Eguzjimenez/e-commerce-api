using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Models;
using Concre_Innova_API.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Cotizaciones
{
    public class CotizacionNotificationRepository
        : ICotizacionNotificationRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public CotizacionNotificationRepository(
            ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<IReadOnlyCollection<CotizacionNotificacionPendiente>>
            ObtenerPendientesAsync(
                int idCotizacion,
                CancellationToken cancellationToken)
        {
            const string query = """
                SELECT TOP (10)
                    N.IdCotizacionNotificacion,
                    COALESCE(
                        NULLIF(LTRIM(RTRIM(U.Correo)), ''),
                        NULLIF(LTRIM(RTRIM(CL.Correo)), '')) AS CorreoDestino,
                    LTRIM(RTRIM(CONCAT(CL.Nombre, ' ', CL.Apellido)))
                        AS NombreCliente,
                    ISNULL(
                        C.NumeroSeguimiento,
                        CONCAT(
                            'COT-',
                            RIGHT(
                                REPLICATE('0', 10) +
                                CONVERT(VARCHAR(10), C.IdCotizacion),
                                10))) AS NumeroSeguimiento,
                    N.EstadoAnterior,
                    N.EstadoNuevo,
                    N.FechaCambio
                FROM dbo.CotizacionNotificaciones N
                INNER JOIN dbo.Cotizaciones C
                    ON C.IdCotizacion = N.IdCotizacion
                INNER JOIN dbo.Clientes CL
                    ON CL.IdCliente = C.IdCliente
                LEFT JOIN dbo.Usuarios U
                    ON U.IdUsuario = CL.IdUsuario
                WHERE N.IdCotizacion = @IdCotizacion
                  AND N.FechaEnvio IS NULL
                  AND N.Intentos < 5
                  AND COALESCE(
                        NULLIF(LTRIM(RTRIM(U.Correo)), ''),
                        NULLIF(LTRIM(RTRIM(CL.Correo)), '')) IS NOT NULL
                ORDER BY N.IdCotizacionNotificacion;
                """;

            var notifications = new List<CotizacionNotificacionPendiente>();
            await using var connection = _connectionFactory.CreateConnection();
            await using var command = new SqlCommand(query, connection);
            command.Parameters.Add("@IdCotizacion", SqlDbType.Int).Value =
                idCotizacion;

            await connection.OpenAsync(cancellationToken);
            await using var reader =
                await command.ExecuteReaderAsync(cancellationToken);

            while (await reader.ReadAsync(cancellationToken))
            {
                notifications.Add(new CotizacionNotificacionPendiente
                {
                    IdCotizacionNotificacion = reader.GetInt32(
                        reader.GetOrdinal("IdCotizacionNotificacion")),
                    CorreoDestino = reader.GetString(
                        reader.GetOrdinal("CorreoDestino")),
                    NombreCliente = reader.GetString(
                        reader.GetOrdinal("NombreCliente")),
                    NumeroSeguimiento = reader.GetString(
                        reader.GetOrdinal("NumeroSeguimiento")),
                    EstadoAnterior = reader.GetString(
                        reader.GetOrdinal("EstadoAnterior")),
                    EstadoNuevo = reader.GetString(
                        reader.GetOrdinal("EstadoNuevo")),
                    FechaCambio = reader.GetDateTime(
                        reader.GetOrdinal("FechaCambio"))
                });
            }

            return notifications;
        }

        public async Task RegistrarResultadoAsync(
            int idCotizacionNotificacion,
            bool enviada,
            CancellationToken cancellationToken)
        {
            const string commandText = """
                UPDATE dbo.CotizacionNotificaciones
                SET
                    Intentos = Intentos + 1,
                    UltimoIntento = SYSDATETIME(),
                    FechaEnvio =
                        CASE
                            WHEN @Enviada = 1 THEN SYSDATETIME()
                            ELSE FechaEnvio
                        END
                WHERE IdCotizacionNotificacion = @IdCotizacionNotificacion
                  AND FechaEnvio IS NULL;
                """;

            await using var connection = _connectionFactory.CreateConnection();
            await using var command = new SqlCommand(commandText, connection);
            command.Parameters.Add(
                "@IdCotizacionNotificacion",
                SqlDbType.Int).Value = idCotizacionNotificacion;
            command.Parameters.Add("@Enviada", SqlDbType.Bit).Value = enviada;

            await connection.OpenAsync(cancellationToken);
            await command.ExecuteNonQueryAsync(cancellationToken);
        }
    }
}

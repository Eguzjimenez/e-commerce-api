using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Models;
using Concre_Innova_API.Domain.Constants;
using Concre_Innova_API.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Notificaciones
{
    public class NotificacionRepository : INotificacionRepository
    {
        private const string SqlUsuarioDePedido = @"
            SELECT TOP (1) C.IdUsuario
            FROM dbo.Pedidos P
            INNER JOIN dbo.Clientes C ON C.IdCliente = P.IdCliente
            WHERE P.IdPedido = @Referencia AND C.IdUsuario IS NOT NULL;";

        private const string SqlUsuarioDeCotizacion = @"
            SELECT TOP (1) C.IdUsuario
            FROM dbo.Cotizaciones CO
            INNER JOIN dbo.Clientes C ON C.IdCliente = CO.IdCliente
            WHERE CO.IdCotizacion = @Referencia AND C.IdUsuario IS NOT NULL;";

        private const string SqlUsuarioDeChat = @"
            SELECT TOP (1) C.IdUsuario
            FROM dbo.Chats CH
            INNER JOIN dbo.Clientes C ON C.IdCliente = CH.IdCliente
            WHERE CH.IdChat = @Referencia AND C.IdUsuario IS NOT NULL;";

        private readonly ISqlConnectionFactory _connectionFactory;

        public NotificacionRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<bool> RegistrarAsync(
            NuevaNotificacion notificacion,
            CancellationToken cancellationToken)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_RegistrarNotificacion", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = notificacion.IdUsuario;
            cmd.Parameters.Add("@Tipo", SqlDbType.VarChar, NotificacionLimites.LongitudTipo).Value =
                notificacion.Tipo;
            cmd.Parameters.Add("@Titulo", SqlDbType.VarChar, NotificacionLimites.LongitudTitulo).Value =
                notificacion.Titulo;
            cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, NotificacionLimites.LongitudMensaje).Value =
                notificacion.Mensaje;
            cmd.Parameters.Add("@Enlace", SqlDbType.VarChar, NotificacionLimites.LongitudEnlace).Value =
                (object?)notificacion.Enlace ?? DBNull.Value;
            cmd.Parameters.Add("@Referencia", SqlDbType.Int).Value =
                (object?)notificacion.Referencia ?? DBNull.Value;

            await conn.OpenAsync(cancellationToken);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

            return await reader.ReadAsync(cancellationToken) && GetInt32(reader, "Codigo") == 1;
        }

        public async Task<NotificacionesPaginaResponseDto> ObtenerAsync(
            int idUsuario,
            bool soloNoLeidas,
            PaginationQuery pagination,
            CancellationToken cancellationToken)
        {
            var respuesta = new NotificacionesPaginaResponseDto
            {
                PageNumber = pagination.PageNumber,
                PageSize = pagination.PageSize
            };

            var notificaciones = new List<NotificacionResponseDto>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerNotificacionesUsuario", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;
            cmd.Parameters.Add("@SoloNoLeidas", SqlDbType.Bit).Value = soloNoLeidas;
            cmd.Parameters.Add("@Pagina", SqlDbType.Int).Value = pagination.PageNumber;
            cmd.Parameters.Add("@TamanoPagina", SqlDbType.Int).Value = pagination.PageSize;

            await conn.OpenAsync(cancellationToken);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

            while (await reader.ReadAsync(cancellationToken))
            {
                notificaciones.Add(MapNotificacion(reader));
            }

            if (await reader.NextResultAsync(cancellationToken) &&
                await reader.ReadAsync(cancellationToken))
            {
                respuesta.TotalItems = GetInt32(reader, "TotalItems");
                respuesta.NoLeidas = GetInt32(reader, "NoLeidas");
            }

            respuesta.Items = notificaciones;
            return respuesta;
        }

        public async Task<NotificacionResumenResponseDto> ObtenerResumenAsync(
            int idUsuario,
            CancellationToken cancellationToken)
        {
            var resumen = new NotificacionResumenResponseDto();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerResumenNotificaciones", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;

            await conn.OpenAsync(cancellationToken);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

            if (!await reader.ReadAsync(cancellationToken))
                return resumen;

            resumen.NoLeidas = GetInt32(reader, "NoLeidas");

            var idNotificacion = GetNullableInt32(reader, "IdNotificacion");
            if (idNotificacion.HasValue)
            {
                resumen.UltimaNoLeida = new NotificacionResponseDto
                {
                    IdNotificacion = idNotificacion.Value,
                    Tipo = GetString(reader, "Tipo"),
                    Titulo = GetString(reader, "Titulo"),
                    Mensaje = GetString(reader, "Mensaje"),
                    Enlace = GetNullableString(reader, "Enlace"),
                    Referencia = GetNullableInt32(reader, "Referencia"),
                    Leida = false,
                    FechaEnvio = GetDateTime(reader, "FechaEnvio")
                };
            }

            return resumen;
        }

        public Task<NotificacionOperacionResponseDto> MarcarLeidaAsync(
            int idUsuario,
            int idNotificacion,
            CancellationToken cancellationToken)
        {
            return EjecutarOperacionAsync(
                "SP_MarcarNotificacionLeida",
                idUsuario,
                idNotificacion,
                cancellationToken);
        }

        public Task<NotificacionOperacionResponseDto> MarcarTodasLeidasAsync(
            int idUsuario,
            CancellationToken cancellationToken)
        {
            return EjecutarOperacionAsync(
                "SP_MarcarNotificacionesLeidas",
                idUsuario,
                idNotificacion: null,
                cancellationToken);
        }

        public Task<int?> ObtenerUsuarioDePedidoAsync(
            int idPedido,
            CancellationToken cancellationToken)
        {
            return ObtenerUsuarioAsync(SqlUsuarioDePedido, idPedido, cancellationToken);
        }

        public Task<int?> ObtenerUsuarioDeCotizacionAsync(
            int idCotizacion,
            CancellationToken cancellationToken)
        {
            return ObtenerUsuarioAsync(SqlUsuarioDeCotizacion, idCotizacion, cancellationToken);
        }

        public Task<int?> ObtenerUsuarioDeChatAsync(
            int idChat,
            CancellationToken cancellationToken)
        {
            return ObtenerUsuarioAsync(SqlUsuarioDeChat, idChat, cancellationToken);
        }

        private async Task<NotificacionOperacionResponseDto> EjecutarOperacionAsync(
            string storedProcedure,
            int idUsuario,
            int? idNotificacion,
            CancellationToken cancellationToken)
        {
            var resultado = new NotificacionOperacionResponseDto();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand(storedProcedure, conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;

            if (idNotificacion.HasValue)
            {
                cmd.Parameters.Add("@IdNotificacion", SqlDbType.Int).Value = idNotificacion.Value;
            }

            await conn.OpenAsync(cancellationToken);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

            if (await reader.ReadAsync(cancellationToken))
            {
                resultado.Exitoso = GetInt32(reader, "Codigo") == 1;
                resultado.Mensaje = GetString(reader, "Mensaje");
                resultado.NoLeidas = GetInt32(reader, "NoLeidas");
            }

            return resultado;
        }

        private async Task<int?> ObtenerUsuarioAsync(
            string sql,
            int referencia,
            CancellationToken cancellationToken)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand(sql, conn);

            cmd.Parameters.Add("@Referencia", SqlDbType.Int).Value = referencia;

            await conn.OpenAsync(cancellationToken);
            var resultado = await cmd.ExecuteScalarAsync(cancellationToken);

            return resultado is null || resultado == DBNull.Value
                ? null
                : Convert.ToInt32(resultado);
        }

        private static NotificacionResponseDto MapNotificacion(SqlDataReader reader)
        {
            return new NotificacionResponseDto
            {
                IdNotificacion = GetInt32(reader, "IdNotificacion"),
                Tipo = GetString(reader, "Tipo"),
                Titulo = GetString(reader, "Titulo"),
                Mensaje = GetString(reader, "Mensaje"),
                Enlace = GetNullableString(reader, "Enlace"),
                Referencia = GetNullableInt32(reader, "Referencia"),
                Leida = GetBoolean(reader, "Leida"),
                FechaEnvio = GetDateTime(reader, "FechaEnvio"),
                FechaLectura = GetNullableDateTime(reader, "FechaLectura")
            };
        }

        private static int GetInt32(SqlDataReader reader, string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? 0 : reader.GetInt32(ordinal);
        }

        private static int? GetNullableInt32(SqlDataReader reader, string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? null : reader.GetInt32(ordinal);
        }

        private static string GetString(SqlDataReader reader, string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? string.Empty : reader.GetString(ordinal);
        }

        private static string? GetNullableString(SqlDataReader reader, string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? null : reader.GetString(ordinal);
        }

        private static bool GetBoolean(SqlDataReader reader, string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return !reader.IsDBNull(ordinal) && reader.GetBoolean(ordinal);
        }

        private static DateTime GetDateTime(SqlDataReader reader, string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? DateTime.MinValue : reader.GetDateTime(ordinal);
        }

        private static DateTime? GetNullableDateTime(SqlDataReader reader, string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? null : reader.GetDateTime(ordinal);
        }
    }
}

using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Domain.Constants;
using Concre_Innova_API.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Chat
{
    public class ChatRepository : IChatRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public ChatRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<int?> ObtenerOCrearChatAsync(
            int idUsuario,
            CancellationToken cancellationToken)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerOCrearChatCliente", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;

            await conn.OpenAsync(cancellationToken);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

            if (!await reader.ReadAsync(cancellationToken))
                return null;

            return GetInt32(reader, "Codigo") == 1
                ? GetNullableInt32(reader, "IdChat")
                : null;
        }

        public async Task<ChatMensajeResponseDto?> RegistrarMensajeAsync(
            int idChat,
            string remitente,
            string mensaje,
            CancellationToken cancellationToken)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_RegistrarMensajeChat", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdChat", SqlDbType.Int).Value = idChat;
            cmd.Parameters.Add("@Remitente", SqlDbType.VarChar, 100).Value = remitente;
            cmd.Parameters.Add("@Mensaje", SqlDbType.NVarChar, 1000).Value = mensaje;

            await conn.OpenAsync(cancellationToken);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

            if (!await reader.ReadAsync(cancellationToken) || GetInt32(reader, "Codigo") != 1)
                return null;

            return new ChatMensajeResponseDto
            {
                IdMensaje = GetNullableInt32(reader, "IdMensaje") ?? 0,
                IdChat = idChat,
                Remitente = remitente,
                Mensaje = mensaje,
                FechaHora = DateTime.Now
            };
        }

        public async Task<ChatConversacionResponseDto> ObtenerConversacionAsync(
            int idUsuario,
            CancellationToken cancellationToken)
        {
            var conversacion = new ChatConversacionResponseDto();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerConversacionCliente", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;

            await conn.OpenAsync(cancellationToken);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

            if (await reader.ReadAsync(cancellationToken))
            {
                conversacion.IdChat = GetInt32(reader, "IdChat");
                conversacion.Estado = GetString(reader, "Estado");
                conversacion.FechaInicio = GetNullableDateTime(reader, "FechaInicio");
                conversacion.FechaCierre = GetNullableDateTime(reader, "FechaCierre");
            }

            if (await reader.NextResultAsync(cancellationToken))
            {
                while (await reader.ReadAsync(cancellationToken))
                {
                    conversacion.Mensajes.Add(MapMensaje(reader));
                }
            }

            return conversacion;
        }

        public async Task<ChatOperacionResponseDto> EscalarASoporteAsync(
            int idChat,
            string mensajeNotificacion,
            CancellationToken cancellationToken)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_EscalarChatASoporte", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdChat", SqlDbType.Int).Value = idChat;
            cmd.Parameters.Add("@MensajeNotificacion", SqlDbType.NVarChar, 500).Value =
                mensajeNotificacion;

            await conn.OpenAsync(cancellationToken);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

            return await LeerOperacionAsync(reader, ChatEstados.Escalado, cancellationToken);
        }

        public async Task<ChatOperacionResponseDto> FinalizarAsync(
            int idChat,
            CancellationToken cancellationToken)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_FinalizarChat", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdChat", SqlDbType.Int).Value = idChat;

            await conn.OpenAsync(cancellationToken);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

            return await LeerOperacionAsync(reader, ChatEstados.Finalizado, cancellationToken);
        }

        public async Task<IReadOnlyList<ChatAdminResponseDto>> ObtenerChatsAdminAsync(
            string? estado,
            CancellationToken cancellationToken)
        {
            var conversaciones = new List<ChatAdminResponseDto>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerChatsAdmin", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@Estado", SqlDbType.VarChar, 30).Value =
                string.IsNullOrWhiteSpace(estado) ? DBNull.Value : estado.Trim();

            await conn.OpenAsync(cancellationToken);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

            while (await reader.ReadAsync(cancellationToken))
            {
                conversaciones.Add(new ChatAdminResponseDto
                {
                    IdChat = GetInt32(reader, "IdChat"),
                    IdCliente = GetInt32(reader, "IdCliente"),
                    Cliente = GetString(reader, "Cliente"),
                    CorreoCliente = GetString(reader, "CorreoCliente"),
                    Estado = GetString(reader, "Estado"),
                    FechaInicio = GetNullableDateTime(reader, "FechaInicio"),
                    FechaCierre = GetNullableDateTime(reader, "FechaCierre"),
                    IdUsuarioSoporte = GetNullableInt32(reader, "IdUsuarioSoporte"),
                    UltimoMensaje = GetString(reader, "UltimoMensaje"),
                    FechaUltimoMensaje = GetNullableDateTime(reader, "FechaUltimoMensaje"),
                    TotalMensajes = GetInt32(reader, "TotalMensajes")
                });
            }

            return conversaciones;
        }

        public async Task<IReadOnlyList<ChatMensajeResponseDto>> ObtenerMensajesAsync(
            int idChat,
            CancellationToken cancellationToken)
        {
            var mensajes = new List<ChatMensajeResponseDto>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerMensajesChat", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdChat", SqlDbType.Int).Value = idChat;

            await conn.OpenAsync(cancellationToken);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

            while (await reader.ReadAsync(cancellationToken))
            {
                mensajes.Add(MapMensaje(reader));
            }

            return mensajes;
        }

        private static async Task<ChatOperacionResponseDto> LeerOperacionAsync(
            SqlDataReader reader,
            string estadoEsperado,
            CancellationToken cancellationToken)
        {
            if (!await reader.ReadAsync(cancellationToken))
            {
                return new ChatOperacionResponseDto
                {
                    Exitoso = false,
                    Mensaje = "No fue posible completar la operacion del chat."
                };
            }

            var exitoso = GetInt32(reader, "Codigo") == 1;

            return new ChatOperacionResponseDto
            {
                Exitoso = exitoso,
                Mensaje = GetString(reader, "Mensaje"),
                Estado = exitoso ? estadoEsperado : string.Empty
            };
        }

        private static ChatMensajeResponseDto MapMensaje(SqlDataReader reader)
        {
            return new ChatMensajeResponseDto
            {
                IdMensaje = GetInt32(reader, "IdMensaje"),
                IdChat = GetInt32(reader, "IdChat"),
                Remitente = GetString(reader, "Remitente"),
                Mensaje = GetString(reader, "Mensaje"),
                FechaHora = GetNullableDateTime(reader, "FechaHora") ?? DateTime.Now
            };
        }

        private static string GetString(SqlDataReader reader, string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? string.Empty : reader.GetString(ordinal);
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

        private static DateTime? GetNullableDateTime(SqlDataReader reader, string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? null : reader.GetDateTime(ordinal);
        }
    }
}

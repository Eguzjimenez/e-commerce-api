using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Preferencias
{
    public class PreferenciasRepository : IPreferenciasRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public PreferenciasRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<PreferenciasUsuarioResponseDto> ObtenerAsync(int idUsuario)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerPreferenciasUsuario", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new PreferenciasUsuarioResponseDto
                {
                    IdUsuario = reader.GetInt32(reader.GetOrdinal("IdUsuario")),
                    NotificacionesActivas = reader.GetBoolean(reader.GetOrdinal("NotificacionesActivas")),
                    NotificacionesCorreo = reader.GetBoolean(reader.GetOrdinal("NotificacionesCorreo")),
                    Tema = reader.GetString(reader.GetOrdinal("Tema")),
                    FechaActualizacion = reader.GetDateTime(reader.GetOrdinal("FechaActualizacion"))
                };
            }

            return new PreferenciasUsuarioResponseDto { IdUsuario = idUsuario };
        }

        public async Task<OperacionResponseDto> ActualizarAsync(
            int idUsuario,
            ActualizarPreferenciasRequest request)
        {
            var resultado = new OperacionResponseDto();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ActualizarPreferenciasUsuario", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;
            cmd.Parameters.Add("@NotificacionesActivas", SqlDbType.Bit).Value = request.NotificacionesActivas;
            cmd.Parameters.Add("@NotificacionesCorreo", SqlDbType.Bit).Value = request.NotificacionesCorreo;
            cmd.Parameters.Add("@Tema", SqlDbType.VarChar, 20).Value =
                string.IsNullOrWhiteSpace(request.Tema) ? "claro" : request.Tema.Trim().ToLowerInvariant();

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                resultado.Codigo = reader.GetInt32(reader.GetOrdinal("Codigo"));
                resultado.Mensaje = reader.GetString(reader.GetOrdinal("Mensaje"));
            }

            return resultado;
        }
    }
}

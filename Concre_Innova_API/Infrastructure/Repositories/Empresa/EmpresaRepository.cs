using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Models;
using Concre_Innova_API.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Empresa
{
    public class EmpresaRepository : IEmpresaRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public EmpresaRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<InformacionEmpresaResponseDto?> ObtenerInformacionAsync()
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerInformacionEmpresa", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync())
            {
                return null;
            }

            return new InformacionEmpresaResponseDto
            {
                IdInformacion = reader.GetInt32(reader.GetOrdinal("IdInformacion")),
                NombreEmpresa = reader.GetString(reader.GetOrdinal("NombreEmpresa")),
                Descripcion = reader.GetString(reader.GetOrdinal("Descripcion")),
                Correo = reader.GetString(reader.GetOrdinal("Correo")),
                Telefono = reader.GetString(reader.GetOrdinal("Telefono")),
                WhatsApp = reader.GetString(reader.GetOrdinal("WhatsApp")),
                Direccion = reader.GetString(reader.GetOrdinal("Direccion")),
                Horario = reader.GetString(reader.GetOrdinal("Horario")),
                Facebook = reader.GetString(reader.GetOrdinal("Facebook")),
                Instagram = reader.GetString(reader.GetOrdinal("Instagram")),
                TikTok = reader.GetString(reader.GetOrdinal("TikTok")),
                FechaActualizacion = reader.GetDateTime(reader.GetOrdinal("FechaActualizacion"))
            };
        }

        public async Task<OperacionResponseDto> ActualizarInformacionAsync(
            ActualizarInformacionEmpresaRequest request,
            int idUsuario)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ActualizarInformacionEmpresa", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@NombreEmpresa", SqlDbType.VarChar, 150).Value = Texto(request.NombreEmpresa);
            cmd.Parameters.Add("@Descripcion", SqlDbType.VarChar, 1000).Value = Texto(request.Descripcion);
            cmd.Parameters.Add("@Correo", SqlDbType.VarChar, 150).Value = Texto(request.Correo);
            cmd.Parameters.Add("@Telefono", SqlDbType.VarChar, 50).Value = Texto(request.Telefono);
            cmd.Parameters.Add("@WhatsApp", SqlDbType.VarChar, 50).Value = Texto(request.WhatsApp);
            cmd.Parameters.Add("@Direccion", SqlDbType.VarChar, 255).Value = Texto(request.Direccion);
            cmd.Parameters.Add("@Horario", SqlDbType.VarChar, 255).Value = Texto(request.Horario);
            cmd.Parameters.Add("@Facebook", SqlDbType.VarChar, 255).Value = Texto(request.Facebook);
            cmd.Parameters.Add("@Instagram", SqlDbType.VarChar, 255).Value = Texto(request.Instagram);
            cmd.Parameters.Add("@TikTok", SqlDbType.VarChar, 255).Value = Texto(request.TikTok);
            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;

            return await EjecutarOperacionAsync(conn, cmd);
        }

        public async Task<OperacionResponseDto> RegistrarMensajeAsync(
            CrearMensajeContactoRequest request,
            int? idUsuario)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_RegistrarMensajeContacto", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@Nombre", SqlDbType.VarChar, 150).Value = Texto(request.Nombre);
            cmd.Parameters.Add("@Correo", SqlDbType.VarChar, 150).Value = Texto(request.Correo);
            cmd.Parameters.Add("@Telefono", SqlDbType.VarChar, 50).Value = Texto(request.Telefono);
            cmd.Parameters.Add("@Asunto", SqlDbType.VarChar, 150).Value = Texto(request.Asunto);
            cmd.Parameters.Add("@Mensaje", SqlDbType.VarChar, 2000).Value = Texto(request.Mensaje);
            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value =
                idUsuario.HasValue ? idUsuario.Value : DBNull.Value;

            return await EjecutarOperacionAsync(conn, cmd);
        }

        public async Task<PaginatedResponseDto<MensajeContactoResponseDto>> ObtenerMensajesAsync(
            string? estado,
            PaginationQuery pagination)
        {
            var mensajes = new List<MensajeContactoResponseDto>();
            var totalItems = 0;

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerMensajesContacto", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@Estado", SqlDbType.VarChar, 20).Value = Opcional(estado);
            cmd.Parameters.Add("@Pagina", SqlDbType.Int).Value = pagination.PageNumber;
            cmd.Parameters.Add("@TamanoPagina", SqlDbType.Int).Value = pagination.PageSize;

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                mensajes.Add(new MensajeContactoResponseDto
                {
                    IdMensaje = reader.GetInt32(reader.GetOrdinal("IdMensaje")),
                    Nombre = reader.GetString(reader.GetOrdinal("Nombre")),
                    Correo = reader.GetString(reader.GetOrdinal("Correo")),
                    Telefono = reader.GetString(reader.GetOrdinal("Telefono")),
                    Asunto = reader.GetString(reader.GetOrdinal("Asunto")),
                    Mensaje = reader.GetString(reader.GetOrdinal("Mensaje")),
                    Estado = reader.GetString(reader.GetOrdinal("Estado")),
                    FechaEnvio = reader.GetDateTime(reader.GetOrdinal("FechaEnvio")),
                    Respuesta = reader.GetString(reader.GetOrdinal("Respuesta")),
                    FechaRespuesta = reader.IsDBNull(reader.GetOrdinal("FechaRespuesta"))
                        ? null
                        : reader.GetDateTime(reader.GetOrdinal("FechaRespuesta"))
                });

                totalItems = reader.GetInt32(reader.GetOrdinal("TotalItems"));
            }

            return new PaginatedResponseDto<MensajeContactoResponseDto>
            {
                Items = mensajes,
                TotalItems = totalItems,
                PageNumber = pagination.PageNumber,
                PageSize = pagination.PageSize
            };
        }

        public async Task<ConsultaRespondida> ResponderMensajeAsync(
            int idMensaje,
            string respuesta,
            int idUsuario)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ResponderMensajeContacto", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdMensaje", SqlDbType.Int).Value = idMensaje;
            cmd.Parameters.Add("@Respuesta", SqlDbType.VarChar, 2000).Value = respuesta;
            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();

            if (!await reader.ReadAsync())
            {
                return new ConsultaRespondida
                {
                    Exitoso = false,
                    Mensaje = "No fue posible registrar la respuesta."
                };
            }

            var codigo = reader.GetInt32(reader.GetOrdinal("Codigo"));

            return new ConsultaRespondida
            {
                Exitoso = codigo == 1,
                Mensaje = reader.GetString(reader.GetOrdinal("Mensaje")),
                CorreoCliente = LeerTextoOpcional(reader, "Correo"),
                NombreCliente = LeerTextoOpcional(reader, "Nombre"),
                Asunto = LeerTextoOpcional(reader, "Asunto")
            };
        }

        private static string LeerTextoOpcional(SqlDataReader reader, string columna)
        {
            var ordinal = reader.GetOrdinal(columna);
            return reader.IsDBNull(ordinal) ? string.Empty : reader.GetString(ordinal);
        }

        private static async Task<OperacionResponseDto> EjecutarOperacionAsync(
            SqlConnection conn,
            SqlCommand cmd)
        {
            var resultado = new OperacionResponseDto();

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                resultado.Codigo = reader.GetInt32(reader.GetOrdinal("Codigo"));
                resultado.Mensaje = reader.GetString(reader.GetOrdinal("Mensaje"));
            }

            return resultado;
        }

        private static string Texto(string? valor)
        {
            return valor?.Trim() ?? string.Empty;
        }

        private static object Opcional(string? valor)
        {
            return string.IsNullOrWhiteSpace(valor) ? DBNull.Value : valor.Trim();
        }
    }
}

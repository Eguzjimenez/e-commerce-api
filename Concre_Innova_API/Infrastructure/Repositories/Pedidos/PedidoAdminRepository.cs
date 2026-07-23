using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Pedidos
{
    public class PedidoAdminRepository : IPedidoAdminRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public PedidoAdminRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<PaginatedResponseDto<PedidoAdminResponseDto>> ObtenerPedidosAsync(
            PedidoAdminQuery query,
            PaginationQuery pagination)
        {
            var pedidos = new List<PedidoAdminResponseDto>();
            var totalItems = 0;

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerPedidosAdmin", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@Busqueda", SqlDbType.NVarChar, 150).Value =
                GetDatabaseValue(query.Busqueda);
            cmd.Parameters.Add("@Estado", SqlDbType.VarChar, 50).Value =
                GetDatabaseValue(query.Estado);
            cmd.Parameters.Add("@FechaDesde", SqlDbType.Date).Value =
                query.FechaDesde.HasValue ? query.FechaDesde.Value.Date : DBNull.Value;
            cmd.Parameters.Add("@FechaHasta", SqlDbType.Date).Value =
                query.FechaHasta.HasValue ? query.FechaHasta.Value.Date : DBNull.Value;
            cmd.Parameters.Add("@Pagina", SqlDbType.Int).Value = pagination.PageNumber;
            cmd.Parameters.Add("@TamanoPagina", SqlDbType.Int).Value = pagination.PageSize;

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                pedidos.Add(new PedidoAdminResponseDto
                {
                    IdPedido = reader.GetInt32(reader.GetOrdinal("IdPedido")),
                    FechaPedido = reader.GetDateTime(reader.GetOrdinal("FechaPedido")),
                    Estado = reader.GetString(reader.GetOrdinal("Estado")),
                    DireccionEntrega = reader.GetString(reader.GetOrdinal("DireccionEntrega")),
                    Total = reader.GetDecimal(reader.GetOrdinal("Total")),
                    IdCliente = reader.GetInt32(reader.GetOrdinal("IdCliente")),
                    NombreCliente = reader.GetString(reader.GetOrdinal("NombreCliente")),
                    CorreoCliente = reader.GetString(reader.GetOrdinal("CorreoCliente")),
                    MetodoPago = reader.GetString(reader.GetOrdinal("MetodoPago"))
                });

                totalItems = reader.GetInt32(reader.GetOrdinal("TotalItems"));
            }

            return new PaginatedResponseDto<PedidoAdminResponseDto>
            {
                Items = pedidos,
                TotalItems = totalItems,
                PageNumber = pagination.PageNumber,
                PageSize = pagination.PageSize
            };
        }

        public async Task<PedidoAdminDetalleResponseDto?> ObtenerDetalleAsync(int idPedido)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerPedidoAdminDetalle", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdPedido", SqlDbType.Int).Value = idPedido;

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();

            if (!await reader.ReadAsync())
            {
                return null;
            }

            var detallePedido = new PedidoAdminDetalleResponseDto
            {
                IdPedido = reader.GetInt32(reader.GetOrdinal("IdPedido")),
                FechaPedido = reader.GetDateTime(reader.GetOrdinal("FechaPedido")),
                Estado = reader.GetString(reader.GetOrdinal("Estado")),
                DireccionEntrega = reader.GetString(reader.GetOrdinal("DireccionEntrega")),
                Total = reader.GetDecimal(reader.GetOrdinal("Total")),
                IdCliente = reader.GetInt32(reader.GetOrdinal("IdCliente")),
                NombreCliente = reader.GetString(reader.GetOrdinal("NombreCliente")),
                CorreoCliente = reader.GetString(reader.GetOrdinal("CorreoCliente")),
                TelefonoCliente = reader.GetString(reader.GetOrdinal("TelefonoCliente")),
                MetodoPago = reader.GetString(reader.GetOrdinal("MetodoPago")),
                EstadoPago = reader.GetString(reader.GetOrdinal("EstadoPago"))
            };

            if (await reader.NextResultAsync())
            {
                while (await reader.ReadAsync())
                {
                    detallePedido.Detalle.Add(new DetallePedidoAdminDto
                    {
                        IdDetallePedido = reader.GetInt32(reader.GetOrdinal("IdDetallePedido")),
                        IdProducto = reader.GetInt32(reader.GetOrdinal("IdProducto")),
                        IdVariante = reader.IsDBNull(reader.GetOrdinal("IdVariante"))
                            ? null
                            : reader.GetInt32(reader.GetOrdinal("IdVariante")),
                        Nombre = reader.GetString(reader.GetOrdinal("Nombre")),
                        NombreVariante = reader.GetString(reader.GetOrdinal("NombreVariante")),
                        Imagen = reader.GetString(reader.GetOrdinal("Imagen")),
                        Cantidad = reader.GetInt32(reader.GetOrdinal("Cantidad")),
                        PrecioUnitario = reader.GetDecimal(reader.GetOrdinal("PrecioUnitario")),
                        Subtotal = reader.GetDecimal(reader.GetOrdinal("Subtotal"))
                    });
                }
            }

            return detallePedido;
        }

        public async Task<OperacionPedidoResultDto> ActualizarEstadoAsync(
            int idPedido,
            string nuevoEstado,
            int idUsuario)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ActualizarEstadoPedido", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdPedido", SqlDbType.Int).Value = idPedido;
            cmd.Parameters.Add("@NuevoEstado", SqlDbType.VarChar, 50).Value = nuevoEstado;
            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;

            return await EjecutarOperacionAsync(conn, cmd);
        }

        public async Task<OperacionPedidoResultDto> CancelarAsync(int idPedido, int idUsuario)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_CancelarPedido", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdPedido", SqlDbType.Int).Value = idPedido;
            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;

            return await EjecutarOperacionAsync(conn, cmd);
        }

        private static async Task<OperacionPedidoResultDto> EjecutarOperacionAsync(
            SqlConnection conn,
            SqlCommand cmd)
        {
            var resultado = new OperacionPedidoResultDto();

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                resultado.Exitoso = reader.GetInt32(reader.GetOrdinal("Exitoso")) == 1;
                resultado.Mensaje = reader.GetString(reader.GetOrdinal("Mensaje"));
            }

            return resultado;
        }

        private static object GetDatabaseValue(string? value)
        {
            return string.IsNullOrWhiteSpace(value) ? DBNull.Value : value.Trim();
        }
    }
}

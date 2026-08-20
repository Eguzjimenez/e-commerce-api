using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Facturas
{
    public class FacturaRepository : IFacturaRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public FacturaRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<FacturaListadoResponseDto> BuscarAsync(
            FacturaQuery query,
            PaginationQuery pagination,
            CancellationToken cancellationToken)
        {
            var items = new List<FacturaItemResponseDto>();
            var resumen = new FacturaResumenResponseDto();
            var totalItems = 0;

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerFacturasAdmin", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@Busqueda", SqlDbType.NVarChar, 120).Value =
                (object?)Limpiar(query.Busqueda) ?? DBNull.Value;
            cmd.Parameters.Add("@Estado", SqlDbType.VarChar, 30).Value =
                (object?)Limpiar(query.Estado) ?? DBNull.Value;
            cmd.Parameters.Add("@Desde", SqlDbType.Date).Value =
                (object?)query.Desde ?? DBNull.Value;
            cmd.Parameters.Add("@Hasta", SqlDbType.Date).Value =
                (object?)query.Hasta ?? DBNull.Value;
            cmd.Parameters.Add("@Pagina", SqlDbType.Int).Value = pagination.PageNumber;
            cmd.Parameters.Add("@TamanoPagina", SqlDbType.Int).Value = pagination.PageSize;

            await conn.OpenAsync(cancellationToken);

            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
            while (await reader.ReadAsync(cancellationToken))
            {
                items.Add(new FacturaItemResponseDto
                {
                    IdVenta = Entero(reader, "IdVenta"),
                    IdPedido = Entero(reader, "IdPedido"),
                    FechaVenta = Fecha(reader, "FechaVenta") ?? DateTime.MinValue,
                    FechaVencimiento = Fecha(reader, "FechaVencimiento"),
                    MetodoPago = Texto(reader, "MetodoPago"),
                    EstadoPago = Texto(reader, "EstadoPago"),
                    Total = Monto(reader, "Total"),
                    Observaciones = Texto(reader, "Observaciones"),
                    EstadoPedido = Texto(reader, "EstadoPedido"),
                    IdCliente = EnteroNulo(reader, "IdCliente"),
                    Cliente = Texto(reader, "Cliente"),
                    CorreoCliente = Texto(reader, "CorreoCliente"),
                    TotalPagos = Entero(reader, "TotalPagos"),
                    MontoPagado = Monto(reader, "MontoPagado"),
                    EstadoFactura = Texto(reader, "EstadoFactura"),
                    DiasParaVencer = EnteroNulo(reader, "DiasParaVencer")
                });

                totalItems = Entero(reader, "TotalItems");
                resumen = new FacturaResumenResponseDto
                {
                    TotalPagadas = Entero(reader, "TotalPagadas"),
                    TotalPendientes = Entero(reader, "TotalPendientes"),
                    TotalVencidas = Entero(reader, "TotalVencidas"),
                    TotalEnRevision = Entero(reader, "TotalEnRevision"),
                    MontoPorCobrar = Monto(reader, "MontoPorCobrar")
                };
            }

            return new FacturaListadoResponseDto
            {
                Items = items,
                TotalItems = totalItems,
                PageNumber = pagination.PageNumber,
                PageSize = pagination.PageSize,
                Resumen = resumen
            };
        }

        public async Task<FacturaDetalleResponseDto?> ObtenerDetalleAsync(
            int idVenta,
            CancellationToken cancellationToken)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerFacturaDetalle", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdVenta", SqlDbType.Int).Value = idVenta;

            await conn.OpenAsync(cancellationToken);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

            if (!await reader.ReadAsync(cancellationToken))
            {
                return null;
            }

            var detalle = new FacturaDetalleResponseDto
            {
                IdVenta = Entero(reader, "IdVenta"),
                IdPedido = Entero(reader, "IdPedido"),
                FechaVenta = Fecha(reader, "FechaVenta") ?? DateTime.MinValue,
                FechaVencimiento = Fecha(reader, "FechaVencimiento"),
                MetodoPago = Texto(reader, "MetodoPago"),
                EstadoPago = Texto(reader, "EstadoPago"),
                Total = Monto(reader, "Total"),
                Observaciones = Texto(reader, "Observaciones"),
                EstadoPedido = Texto(reader, "EstadoPedido"),
                FechaPedido = Fecha(reader, "FechaPedido"),
                DireccionEntrega = Texto(reader, "DireccionEntrega"),
                Cliente = Texto(reader, "Cliente"),
                CorreoCliente = Texto(reader, "CorreoCliente"),
                TelefonoCliente = Texto(reader, "TelefonoCliente"),
                EstadoFactura = Texto(reader, "EstadoFactura")
            };

            var lineas = new List<FacturaLineaResponseDto>();
            if (await reader.NextResultAsync(cancellationToken))
            {
                while (await reader.ReadAsync(cancellationToken))
                {
                    lineas.Add(new FacturaLineaResponseDto
                    {
                        IdDetalle = Entero(reader, "IdDetalle"),
                        IdProducto = Entero(reader, "IdProducto"),
                        NombreProducto = Texto(reader, "NombreProducto"),
                        NombreVariante = Texto(reader, "NombreVariante"),
                        Cantidad = Entero(reader, "Cantidad"),
                        PrecioUnitario = Monto(reader, "PrecioUnitario"),
                        Subtotal = Monto(reader, "Subtotal")
                    });
                }
            }

            var pagos = new List<FacturaPagoResponseDto>();
            if (await reader.NextResultAsync(cancellationToken))
            {
                while (await reader.ReadAsync(cancellationToken))
                {
                    pagos.Add(new FacturaPagoResponseDto
                    {
                        IdPago = Entero(reader, "IdPago"),
                        Monto = Monto(reader, "Monto"),
                        FechaPago = Fecha(reader, "FechaPago"),
                        MetodoPago = Texto(reader, "MetodoPago"),
                        Referencia = Texto(reader, "Referencia"),
                        ComprobanteArchivo = Texto(reader, "ComprobanteArchivo")
                    });
                }
            }

            detalle.Lineas = lineas;
            detalle.Pagos = pagos;
            return detalle;
        }

        public async Task<OperacionResponseDto> ActualizarEstadoAsync(
            ActualizarEstadoFacturaRequest request,
            int idUsuario,
            CancellationToken cancellationToken)
        {
            var resultado = new OperacionResponseDto();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ActualizarEstadoFactura", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdVenta", SqlDbType.Int).Value = request.IdVenta;
            cmd.Parameters.Add("@EstadoPago", SqlDbType.VarChar, 30).Value =
                request.EstadoPago?.Trim() ?? string.Empty;
            cmd.Parameters.Add("@Observaciones", SqlDbType.VarChar, 400).Value =
                (object?)Limpiar(request.Observaciones) ?? DBNull.Value;
            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;

            await conn.OpenAsync(cancellationToken);

            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
            if (await reader.ReadAsync(cancellationToken))
            {
                resultado.Codigo = Entero(reader, "Codigo");
                resultado.Mensaje = Texto(reader, "Mensaje") ?? string.Empty;
            }

            return resultado;
        }

        private static string? Limpiar(string? valor) =>
            string.IsNullOrWhiteSpace(valor) ? null : valor.Trim();

        private static int Entero(SqlDataReader reader, string columna)
        {
            var i = reader.GetOrdinal(columna);
            return reader.IsDBNull(i) ? 0 : reader.GetInt32(i);
        }

        private static int? EnteroNulo(SqlDataReader reader, string columna)
        {
            var i = reader.GetOrdinal(columna);
            return reader.IsDBNull(i) ? null : reader.GetInt32(i);
        }

        private static decimal Monto(SqlDataReader reader, string columna)
        {
            var i = reader.GetOrdinal(columna);
            return reader.IsDBNull(i) ? 0m : reader.GetDecimal(i);
        }

        private static string? Texto(SqlDataReader reader, string columna)
        {
            var i = reader.GetOrdinal(columna);
            return reader.IsDBNull(i) ? null : reader.GetString(i);
        }

        private static DateTime? Fecha(SqlDataReader reader, string columna)
        {
            var i = reader.GetOrdinal(columna);
            return reader.IsDBNull(i) ? null : reader.GetDateTime(i);
        }
    }
}

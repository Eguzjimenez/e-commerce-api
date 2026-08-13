using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Reportes
{
    public class ReporteRepository : IReporteRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public ReporteRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<ReporteVentasResponseDto> ObtenerVentasPorPeriodoAsync(ReporteVentasQuery query)
        {
            var reporte = new ReporteVentasResponseDto();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ReporteVentasPorPeriodo", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@FechaDesde", SqlDbType.Date).Value = query.FechaDesde.Date;
            cmd.Parameters.Add("@FechaHasta", SqlDbType.Date).Value = query.FechaHasta.Date;
            cmd.Parameters.Add("@IdCategoria", SqlDbType.Int).Value =
                query.IdCategoria.HasValue ? query.IdCategoria.Value : DBNull.Value;

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                reporte.Items.Add(new ReporteVentaItemDto
                {
                    Fecha = reader.GetDateTime(reader.GetOrdinal("Fecha")),
                    Producto = reader.GetString(reader.GetOrdinal("Producto")),
                    Categoria = reader.GetString(reader.GetOrdinal("Categoria")),
                    Unidades = reader.GetInt32(reader.GetOrdinal("Unidades")),
                    Pedidos = reader.GetInt32(reader.GetOrdinal("Pedidos")),
                    Ingresos = reader.GetDecimal(reader.GetOrdinal("Ingresos"))
                });
            }

            if (await reader.NextResultAsync() && await reader.ReadAsync())
            {
                reporte.Totales = new ReporteVentasTotalesDto
                {
                    IngresosTotales = reader.GetDecimal(reader.GetOrdinal("IngresosTotales")),
                    PedidosTotales = reader.GetInt32(reader.GetOrdinal("PedidosTotales")),
                    UnidadesTotales = reader.GetInt32(reader.GetOrdinal("UnidadesTotales"))
                };
            }

            if (await reader.NextResultAsync())
            {
                while (await reader.ReadAsync())
                {
                    reporte.SerieDiaria.Add(new ReporteVentaPorFechaDto
                    {
                        Fecha = reader.GetDateTime(reader.GetOrdinal("Fecha")),
                        Ingresos = reader.GetDecimal(reader.GetOrdinal("Ingresos")),
                        Pedidos = reader.GetInt32(reader.GetOrdinal("Pedidos"))
                    });
                }
            }

            return reporte;
        }

        public async Task<ReporteComparativoResponseDto> ObtenerComparativoAsync(ReporteComparativoQuery query)
        {
            var comparativo = new ReporteComparativoResponseDto
            {
                PeriodoA = new ReportePeriodoDto
                {
                    Etiqueta = "Periodo A",
                    Desde = query.PeriodoADesde.Date,
                    Hasta = query.PeriodoAHasta.Date
                },
                PeriodoB = new ReportePeriodoDto
                {
                    Etiqueta = "Periodo B",
                    Desde = query.PeriodoBDesde.Date,
                    Hasta = query.PeriodoBHasta.Date
                }
            };

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ReporteComparativoPeriodos", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@PeriodoADesde", SqlDbType.Date).Value = query.PeriodoADesde.Date;
            cmd.Parameters.Add("@PeriodoAHasta", SqlDbType.Date).Value = query.PeriodoAHasta.Date;
            cmd.Parameters.Add("@PeriodoBDesde", SqlDbType.Date).Value = query.PeriodoBDesde.Date;
            cmd.Parameters.Add("@PeriodoBHasta", SqlDbType.Date).Value = query.PeriodoBHasta.Date;

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                var periodo = reader.GetString(reader.GetOrdinal("Periodo"));
                var destino = periodo == "A" ? comparativo.PeriodoA : comparativo.PeriodoB;

                destino.Ingresos = reader.GetDecimal(reader.GetOrdinal("Ingresos"));
                destino.Pedidos = reader.GetInt32(reader.GetOrdinal("Pedidos"));
                destino.TicketPromedio = reader.GetDecimal(reader.GetOrdinal("TicketPromedio"));
            }

            return comparativo;
        }

        public async Task<IEnumerable<ProductoMasVendidoResponseDto>> ObtenerProductosMasVendidosAsync(
            DateTime fechaDesde,
            DateTime fechaHasta,
            int top)
        {
            var productos = new List<ProductoMasVendidoResponseDto>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ReporteProductosMasVendidos", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@FechaDesde", SqlDbType.Date).Value = fechaDesde.Date;
            cmd.Parameters.Add("@FechaHasta", SqlDbType.Date).Value = fechaHasta.Date;
            cmd.Parameters.Add("@Top", SqlDbType.Int).Value = top;

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                productos.Add(new ProductoMasVendidoResponseDto
                {
                    IdProducto = reader.GetInt32(reader.GetOrdinal("IdProducto")),
                    Producto = reader.GetString(reader.GetOrdinal("Producto")),
                    Categoria = reader.GetString(reader.GetOrdinal("Categoria")),
                    UnidadesVendidas = reader.GetInt32(reader.GetOrdinal("UnidadesVendidas")),
                    Ingresos = reader.GetDecimal(reader.GetOrdinal("Ingresos"))
                });
            }

            return productos;
        }
    }
}

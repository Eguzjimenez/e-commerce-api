using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Estadisticas
{
    public class EstadisticasRepository : IEstadisticasRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public EstadisticasRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<EstadisticasResumenResponseDto> ObtenerResumenAsync()
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_EstadisticasResumenNegocio", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new EstadisticasResumenResponseDto
                {
                    VentasMesActual = reader.GetDecimal(reader.GetOrdinal("VentasMesActual")),
                    VariacionMesAnteriorPorcentaje = reader.GetDecimal(reader.GetOrdinal("VariacionMesAnteriorPorcentaje")),
                    ProductoDestacado = reader.GetString(reader.GetOrdinal("ProductoDestacado")),
                    ClientesFrecuentes = reader.GetInt32(reader.GetOrdinal("ClientesFrecuentes"))
                };
            }

            return new EstadisticasResumenResponseDto();
        }

        public async Task<EstadisticasDashboardResponseDto> ObtenerDashboardAsync()
        {
            var dashboard = new EstadisticasDashboardResponseDto();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_EstadisticasDashboard", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                dashboard.VentasMes = reader.GetDecimal(reader.GetOrdinal("VentasMes"));
                dashboard.PedidosPendientes = reader.GetInt32(reader.GetOrdinal("PedidosPendientes"));
                dashboard.CotizacionesPendientes = reader.GetInt32(reader.GetOrdinal("CotizacionesPendientes"));
                dashboard.ProductosBajoStock = reader.GetInt32(reader.GetOrdinal("ProductosBajoStock"));
                dashboard.ProductosActivos = reader.GetInt32(reader.GetOrdinal("ProductosActivos"));
            }

            if (await reader.NextResultAsync())
            {
                while (await reader.ReadAsync())
                {
                    dashboard.VentasMensuales.Add(new VentaMensualDto
                    {
                        Periodo = reader.GetString(reader.GetOrdinal("Periodo")),
                        Ingresos = reader.GetDecimal(reader.GetOrdinal("Ingresos"))
                    });
                }
            }

            dashboard.VentasMensuales.Reverse();

            return dashboard;
        }

        public async Task<IEnumerable<ClienteFrecuenteResponseDto>> ObtenerClientesFrecuentesAsync(int top)
        {
            var clientes = new List<ClienteFrecuenteResponseDto>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_EstadisticasClientesFrecuentes", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@Top", SqlDbType.Int).Value = top;

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                clientes.Add(new ClienteFrecuenteResponseDto
                {
                    IdCliente = reader.GetInt32(reader.GetOrdinal("IdCliente")),
                    NombreCliente = reader.GetString(reader.GetOrdinal("NombreCliente")),
                    CantidadPedidos = reader.GetInt32(reader.GetOrdinal("CantidadPedidos")),
                    TotalComprado = reader.GetDecimal(reader.GetOrdinal("TotalComprado"))
                });
            }

            return clientes;
        }

        public async Task<IEnumerable<EstadisticaCategoriaResponseDto>> ObtenerPorCategoriaAsync()
        {
            var categorias = new List<EstadisticaCategoriaResponseDto>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_EstadisticasPorCategoria", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                categorias.Add(new EstadisticaCategoriaResponseDto
                {
                    NombreCategoria = reader.GetString(reader.GetOrdinal("NombreCategoria")),
                    TotalVendido = reader.GetDecimal(reader.GetOrdinal("TotalVendido")),
                    PorcentajeDelTotal = reader.GetDecimal(reader.GetOrdinal("PorcentajeDelTotal"))
                });
            }

            return categorias;
        }

        public async Task<IEnumerable<ProductoDestacadoResponseDto>> ObtenerProductosDestacadosAsync(int top)
        {
            var productos = new List<ProductoDestacadoResponseDto>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_EstadisticasProductosDestacados", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@Top", SqlDbType.Int).Value = top;

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                productos.Add(new ProductoDestacadoResponseDto
                {
                    NombreProducto = reader.GetString(reader.GetOrdinal("NombreProducto")),
                    CantidadVendida = reader.GetInt32(reader.GetOrdinal("CantidadVendida")),
                    PorcentajeRelativo = reader.GetDecimal(reader.GetOrdinal("PorcentajeRelativo"))
                });
            }

            return productos;
        }
    }
}

using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Carrito
{
    public class CarritoRepository : ICarritoRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public CarritoRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<ValidarStockCarritoResponseDto> ValidarStockCarritoAsync(List<ItemCarritoRequest> items)
        {
            var response = new ValidarStockCarritoResponseDto();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ValidarStockCarrito", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            var carritoTable = new DataTable();
            carritoTable.Columns.Add("IdProducto", typeof(int));
            carritoTable.Columns.Add("Cantidad", typeof(int));

            foreach (var item in items)
            {
                carritoTable.Rows.Add(item.IdProducto, item.Cantidad);
            }

            var parametro = new SqlParameter("@Carrito", carritoTable)
            {
                SqlDbType = SqlDbType.Structured,
                TypeName = "TVP_Carrito"
            };

            cmd.Parameters.Add(parametro);

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                response.Items.Add(new ValidacionStockItemDto
                {
                    IdProducto = reader.GetInt32(reader.GetOrdinal("IdProducto")),
                    Nombre = reader.IsDBNull(reader.GetOrdinal("Nombre")) 
                        ? null 
                        : reader.GetString(reader.GetOrdinal("Nombre")),
                    CantidadSolicitada = reader.GetInt32(reader.GetOrdinal("CantidadSolicitada")),
                    StockDisponible = reader.GetInt32(reader.GetOrdinal("StockDisponible")),
                    Estado = reader.GetString(reader.GetOrdinal("Estado"))
                });
            }

            return response;
        }

        public async Task<RegistrarPedidoResponseDto> RegistrarPedidoAsync(RegistrarPedidoRequest request)
        {
            var response = new RegistrarPedidoResponseDto();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_RegistrarPedido", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            var carritoTable = new DataTable();
            carritoTable.Columns.Add("IdProducto", typeof(int));
            carritoTable.Columns.Add("Cantidad", typeof(int));

            foreach (var item in request.Items)
            {
                carritoTable.Rows.Add(item.IdProducto, item.Cantidad);
            }

            cmd.Parameters.AddWithValue("@IdUsuario", request.IdUsuario);
            cmd.Parameters.AddWithValue("@DireccionEntrega", request.DireccionEntrega);
            cmd.Parameters.AddWithValue("@MetodoPago", request.MetodoPago);

            var parametro = new SqlParameter("@Carrito", carritoTable)
            {
                SqlDbType = SqlDbType.Structured,
                TypeName = "TVP_Carrito"
            };

            cmd.Parameters.Add(parametro);

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                response.Exitoso = reader.GetInt32(reader.GetOrdinal("Exitoso")) == 1;
                response.Mensaje = reader.GetString(reader.GetOrdinal("Mensaje"));

                if (response.Exitoso)
                {
                    response.IdPedido = reader.GetInt32(reader.GetOrdinal("IdPedido"));
                    response.IdCliente = reader.GetInt32(reader.GetOrdinal("IdCliente"));
                    response.Total = reader.GetDecimal(reader.GetOrdinal("Total"));
                }
            }

            return response;
        }

        public async Task<MisPedidosResponseDto> ObtenerMisPedidosAsync(int idUsuario)
        {
            var response = new MisPedidosResponseDto
            {
                Exitoso = true
            };

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerMisPedidos", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@IdUsuario", idUsuario);

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();

            // Verificar si es una respuesta de error
            if (reader.HasRows && reader.FieldCount == 2)
            {
                // Puede ser error (Exitoso, Mensaje)
                await reader.ReadAsync();
                var exitoso = reader.GetInt32(reader.GetOrdinal("Exitoso"));

                if (exitoso == 0)
                {
                    response.Exitoso = false;
                    response.Mensaje = reader.GetString(reader.GetOrdinal("Mensaje"));
                    return response;
                }
            }

            // Procesar pedidos
            var pedidosDict = new Dictionary<int, PedidoUsuarioDto>();

            do
            {
                while (await reader.ReadAsync())
                {
                    var idPedido = reader.GetInt32(reader.GetOrdinal("IdPedido"));

                    if (!pedidosDict.ContainsKey(idPedido))
                    {
                        pedidosDict[idPedido] = new PedidoUsuarioDto
                        {
                            IdPedido = idPedido,
                            FechaPedido = reader.GetDateTime(reader.GetOrdinal("FechaPedido")),
                            Estado = reader.GetString(reader.GetOrdinal("Estado")),
                            DireccionEntrega = reader.GetString(reader.GetOrdinal("DireccionEntrega")),
                            Total = reader.GetDecimal(reader.GetOrdinal("Total")),
                            Detalle = new List<DetallePedidoUsuarioDto>()
                        };
                    }

                    pedidosDict[idPedido].Detalle.Add(new DetallePedidoUsuarioDto
                    {
                        IdDetallePedido = reader.GetInt32(reader.GetOrdinal("IdDetallePedido")),
                        IdProducto = reader.GetInt32(reader.GetOrdinal("IdProducto")),
                        Nombre = reader.GetString(reader.GetOrdinal("Nombre")),
                        Imagen = reader.IsDBNull(reader.GetOrdinal("Imagen"))
                            ? null
                            : reader.GetString(reader.GetOrdinal("Imagen")),
                        Cantidad = reader.GetInt32(reader.GetOrdinal("Cantidad")),
                        PrecioUnitario = reader.GetDecimal(reader.GetOrdinal("PrecioUnitario")),
                        Subtotal = reader.GetDecimal(reader.GetOrdinal("Subtotal"))
                    });
                }
            } while (await reader.NextResultAsync());

            response.Pedidos = pedidosDict.Values.ToList();

            return response;
        }
    }
}

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

            cmd.Parameters.Add(CreateOrderItemsParameter(items));

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

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = request.IdUsuario;
            cmd.Parameters.Add("@DireccionEntrega", SqlDbType.VarChar, 255).Value =
                request.DireccionEntrega;
            cmd.Parameters.Add("@MetodoPago", SqlDbType.VarChar, 50).Value =
                request.MetodoPago;
            cmd.Parameters.Add(CreateOrderItemsParameter(request.Items));

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

        public async Task<MisPedidosResponseDto> ObtenerMisPedidosAsync(
            int idUsuario,
            DateTime? fechaDesde,
            DateTime? fechaHasta)
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

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;
            cmd.Parameters.Add("@FechaDesde", SqlDbType.Date).Value =
                fechaDesde.HasValue ? fechaDesde.Value.Date : DBNull.Value;
            cmd.Parameters.Add("@FechaHasta", SqlDbType.Date).Value =
                fechaHasta.HasValue ? fechaHasta.Value.Date : DBNull.Value;

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
                            MetodoPago = GetOptionalString(reader, "MetodoPago"),
                            EstadoPago = GetOptionalString(reader, "EstadoPago"),
                            Total = reader.GetDecimal(reader.GetOrdinal("Total")),
                            Detalle = new List<DetallePedidoUsuarioDto>()
                        };
                    }

                    pedidosDict[idPedido].Detalle.Add(new DetallePedidoUsuarioDto
                    {
                        IdDetallePedido = reader.GetInt32(reader.GetOrdinal("IdDetallePedido")),
                        IdProducto = reader.GetInt32(reader.GetOrdinal("IdProducto")),
                        IdVariante = GetOptionalNullableInt(reader, "IdVariante"),
                        Nombre = reader.GetString(reader.GetOrdinal("Nombre")),
                        NombreVariante = GetOptionalString(reader, "NombreVariante"),
                        Tamano = GetOptionalString(reader, "Tamano"),
                        Material = GetOptionalString(reader, "Material"),
                        Color = GetOptionalString(reader, "Color"),
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

        public async Task<RecompraPedidoResponseDto> PrepararRecompraPedidoAsync(
            int idUsuario,
            int idPedido)
        {
            var response = new RecompraPedidoResponseDto();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_PrepararRecompraPedido", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;
            cmd.Parameters.Add("@IdPedido", SqlDbType.Int).Value = idPedido;

            await conn.OpenAsync();
            await using var reader = await cmd.ExecuteReaderAsync();

            if (reader.FieldCount == 2)
            {
                if (await reader.ReadAsync())
                {
                    response.Exitoso = false;
                    response.Mensaje = reader.GetString(reader.GetOrdinal("Mensaje"));
                }

                return response;
            }

            while (await reader.ReadAsync())
            {
                response.Items.Add(new RecompraPedidoItemDto
                {
                    IdProducto = reader.GetInt32(reader.GetOrdinal("IdProducto")),
                    IdVariante = GetOptionalNullableInt(reader, "IdVariante"),
                    Nombre = GetOptionalString(reader, "Nombre"),
                    Descripcion = GetOptionalString(reader, "Descripcion"),
                    Precio = reader.GetDecimal(reader.GetOrdinal("Precio")),
                    Imagen = GetOptionalString(reader, "Imagen"),
                    NombreVariante = GetOptionalString(reader, "NombreVariante"),
                    Tamano = GetOptionalString(reader, "Tamano"),
                    Material = GetOptionalString(reader, "Material"),
                    Color = GetOptionalString(reader, "Color"),
                    Cantidad = reader.GetInt32(reader.GetOrdinal("Cantidad")),
                    Disponible = reader.GetBoolean(reader.GetOrdinal("Disponible")),
                    MotivoNoDisponible = GetOptionalString(reader, "MotivoNoDisponible")
                });
            }

            response.Exitoso = response.Items.Any(item => item.Disponible);
            response.Mensaje = response.Exitoso
                ? "Productos preparados para recompra."
                : "Ningun producto del pedido esta disponible actualmente.";

            return response;
        }

        private static SqlParameter CreateOrderItemsParameter(IEnumerable<ItemCarritoRequest> items)
        {
            var orderItemsTable = new DataTable();
            orderItemsTable.Columns.Add("IdProducto", typeof(int));
            orderItemsTable.Columns.Add("IdVariante", typeof(int));
            orderItemsTable.Columns.Add("Cantidad", typeof(int));
            orderItemsTable.Columns.Add("NombreVariante", typeof(string));
            orderItemsTable.Columns.Add("Tamano", typeof(string));
            orderItemsTable.Columns.Add("Material", typeof(string));
            orderItemsTable.Columns.Add("Color", typeof(string));

            foreach (var item in items)
            {
                orderItemsTable.Rows.Add(
                    item.IdProducto,
                    item.IdVariante.HasValue ? item.IdVariante.Value : DBNull.Value,
                    item.Cantidad,
                    GetDatabaseValue(item.NombreVariante),
                    GetDatabaseValue(item.Tamano),
                    GetDatabaseValue(item.Material),
                    GetDatabaseValue(item.Color));
            }

            return new SqlParameter("@Carrito", orderItemsTable)
            {
                SqlDbType = SqlDbType.Structured,
                TypeName = "TVP_PedidoItem"
            };
        }

        private static object GetDatabaseValue(string? value)
        {
            return string.IsNullOrWhiteSpace(value) ? DBNull.Value : value.Trim();
        }

        private static int? GetOptionalNullableInt(SqlDataReader reader, string columnName)
        {
            try
            {
                var ordinal = reader.GetOrdinal(columnName);
                return reader.IsDBNull(ordinal) ? null : reader.GetInt32(ordinal);
            }
            catch (IndexOutOfRangeException)
            {
                return null;
            }
        }

        private static string GetOptionalString(SqlDataReader reader, string columnName)
        {
            try
            {
                var ordinal = reader.GetOrdinal(columnName);
                return reader.IsDBNull(ordinal) ? string.Empty : reader.GetString(ordinal);
            }
            catch (IndexOutOfRangeException)
            {
                return string.Empty;
            }
        }
    }
}

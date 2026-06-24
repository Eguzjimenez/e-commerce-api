using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Catalogo
{
    public class CatalogoRepository : ICatalogoRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public CatalogoRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<IEnumerable<CatalogoProductoResponseDto>> ObtenerCatalogoProductosAsync()
        {
            var list = new List<CatalogoProductoResponseDto>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerCatalogoProductos", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new CatalogoProductoResponseDto
                {
                    IdProducto = reader.GetInt32(reader.GetOrdinal("IdProducto")),
                    Nombre = reader.GetString(reader.GetOrdinal("Nombre")),
                    Descripcion = reader.GetString(reader.GetOrdinal("Descripcion")),
                    Precio = reader.GetDecimal(reader.GetOrdinal("Precio")),
                    Imagen = reader.GetString(reader.GetOrdinal("Imagen")),
                    IdCategoria = reader.GetInt32(reader.GetOrdinal("IdCategoria")),
                    NombreCategoria = reader.GetString(reader.GetOrdinal("NombreCategoria")),
                    Stock = reader.GetInt32(reader.GetOrdinal("Stock")),
                    Disponibilidad = reader.GetString(reader.GetOrdinal("Disponibilidad"))
                });
            }

            return list;
        }

        public async Task<IEnumerable<CategoriaResponseDto>> ObtenerCategoriasAsync()
        {
            var list = new List<CategoriaResponseDto>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerCategorias", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new CategoriaResponseDto
                {
                    IdCategoria = reader.GetInt32(reader.GetOrdinal("IdCategoria")),
                    NombreCategoria = reader.GetString(reader.GetOrdinal("NombreCategoria")),
                    Descripcion = reader.GetString(reader.GetOrdinal("Descripcion")),
                    Estado = reader.GetString(reader.GetOrdinal("Estado"))
                });
            }

            return list;
        }

        public async Task<OperacionResponseDto> InsertarProductoAsync(CreateProductoRequest request)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_InsertarProducto", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@Nombre", request.Nombre);
            cmd.Parameters.AddWithValue("@Descripcion", request.Descripcion);
            cmd.Parameters.AddWithValue("@Precio", request.Precio);
            cmd.Parameters.AddWithValue("@Imagen", request.Imagen);
            cmd.Parameters.AddWithValue("@IdCategoria", request.IdCategoria);
            cmd.Parameters.AddWithValue("@CantidadDisponible", request.CantidadDisponible);
            cmd.Parameters.AddWithValue("@CantidadMinima", request.CantidadMinima);

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                var response = new OperacionResponseDto
                {
                    Codigo = reader.GetInt32(reader.GetOrdinal("Codigo")),
                    Mensaje = reader.GetString(reader.GetOrdinal("Mensaje"))
                };

                var idProductoOrdinal = reader.GetOrdinal("IdProducto");
                if (!reader.IsDBNull(idProductoOrdinal))
                {
                    response.IdProducto = reader.GetInt32(idProductoOrdinal);
                }

                return response;
            }

            return new OperacionResponseDto
            {
                Codigo = -1,
                Mensaje = "No se recibió respuesta del servidor."
            };
        }

        public async Task<OperacionResponseDto> ActualizarProductoAsync(UpdateProductoRequest request)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ActualizarProducto", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@IdProducto", request.IdProducto);
            cmd.Parameters.AddWithValue("@Nombre", request.Nombre);
            cmd.Parameters.AddWithValue("@Descripcion", request.Descripcion);
            cmd.Parameters.AddWithValue("@Precio", request.Precio);
            cmd.Parameters.AddWithValue("@Imagen", (object?)request.Imagen ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@IdCategoria", request.IdCategoria);
            cmd.Parameters.AddWithValue("@CantidadDisponible", request.CantidadDisponible);
            cmd.Parameters.AddWithValue("@CantidadMinima", request.CantidadMinima);
            cmd.Parameters.AddWithValue("@Estado", request.Estado);

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new OperacionResponseDto
                {
                    Codigo = reader.GetInt32(reader.GetOrdinal("Codigo")),
                    Mensaje = reader.GetString(reader.GetOrdinal("Mensaje"))
                };
            }

            return new OperacionResponseDto
            {
                Codigo = -1,
                Mensaje = "No se recibió respuesta del servidor."
            };
        }

        public async Task<OperacionResponseDto> EliminarProductoAsync(int idProducto)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_EliminarProducto", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@IdProducto", idProducto);

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new OperacionResponseDto
                {
                    Codigo = reader.GetInt32(reader.GetOrdinal("Codigo")),
                    Mensaje = reader.GetString(reader.GetOrdinal("Mensaje"))
                };
            }

            return new OperacionResponseDto
            {
                Codigo = -1,
                Mensaje = "No se recibió respuesta del servidor."
            };
        }
    }
}

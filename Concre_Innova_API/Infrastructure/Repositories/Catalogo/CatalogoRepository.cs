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
        private const string NoServerResponseMessage = "No se recibio respuesta del servidor.";

        private readonly ISqlConnectionFactory _connectionFactory;

        public CatalogoRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<IEnumerable<CatalogoProductoResponseDto>> ObtenerCatalogoProductosAsync()
        {
            return await BuscarCatalogoProductosAsync(new CatalogoProductoQuery());
        }

        public async Task<IEnumerable<CatalogoProductoResponseDto>> BuscarCatalogoProductosAsync(CatalogoProductoQuery query)
        {
            var productos = new List<CatalogoProductoResponseDto>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = CreateCatalogQueryCommand(conn, query);

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                productos.Add(MapCatalogProduct(reader));
            }

            return productos;
        }

        public async Task<CatalogoProductoResponseDto?> ObtenerProductoPorIdAsync(int idProducto)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = CreateCatalogQueryCommand(conn, new CatalogoProductoQuery());

            cmd.Parameters["@IdProducto"].Value = idProducto;

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            return await reader.ReadAsync() ? MapCatalogProduct(reader) : null;
        }

        public async Task<IEnumerable<CategoriaResponseDto>> ObtenerCategoriasAsync()
        {
            var categorias = new List<CategoriaResponseDto>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand(
                """
                SELECT
                    IdCategoria,
                    NombreCategoria,
                    ISNULL(Descripcion, '') AS Descripcion,
                    ISNULL(Estado, 'Activo') AS Estado
                FROM Categorias
                WHERE ISNULL(Estado, 'Activo') = 'Activo'
                ORDER BY NombreCategoria;
                """,
                conn)
            {
                CommandType = CommandType.Text
            };

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                categorias.Add(new CategoriaResponseDto
                {
                    IdCategoria = GetInt32(reader, "IdCategoria"),
                    NombreCategoria = GetString(reader, "NombreCategoria"),
                    Descripcion = GetString(reader, "Descripcion"),
                    Estado = GetString(reader, "Estado")
                });
            }

            return categorias;
        }

        public async Task<OperacionResponseDto> InsertarProductoAsync(CreateProductoRequest request)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await conn.OpenAsync();
            await using var transaction = await conn.BeginTransactionAsync();

            try
            {
                await using var insertProductCommand = new SqlCommand(
                    """
                    INSERT INTO Productos
                        (Nombre, Descripcion, Precio, Stock, Imagen, Estado, IdCategoria)
                    OUTPUT INSERTED.IdProducto
                    VALUES
                        (@Nombre, @Descripcion, @Precio, @CantidadDisponible, @Imagen, 'Activo', @IdCategoria);
                    """,
                    conn,
                    (SqlTransaction)transaction)
                {
                    CommandType = CommandType.Text
                };

                AddProductParameters(insertProductCommand, request);
                var productId = Convert.ToInt32(await insertProductCommand.ExecuteScalarAsync());

                await using var insertInventoryCommand = new SqlCommand(
                    """
                    INSERT INTO Inventario
                        (IdProducto, CantidadDisponible, CantidadMinima)
                    VALUES
                        (@IdProducto, @CantidadDisponible, @CantidadMinima);
                    """,
                    conn,
                    (SqlTransaction)transaction)
                {
                    CommandType = CommandType.Text
                };

                insertInventoryCommand.Parameters.Add("@IdProducto", SqlDbType.Int).Value = productId;
                insertInventoryCommand.Parameters.Add("@CantidadDisponible", SqlDbType.Int).Value = request.CantidadDisponible;
                insertInventoryCommand.Parameters.Add("@CantidadMinima", SqlDbType.Int).Value = request.CantidadMinima;

                await insertInventoryCommand.ExecuteNonQueryAsync();
                await transaction.CommitAsync();

                return new OperacionResponseDto
                {
                    Codigo = 1,
                    Mensaje = "Producto creado exitosamente.",
                    IdProducto = productId
                };
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }

        }

        public async Task<OperacionResponseDto> ActualizarProductoAsync(UpdateProductoRequest request)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await conn.OpenAsync();
            await using var transaction = await conn.BeginTransactionAsync();

            try
            {
                await using var updateProductCommand = new SqlCommand(
                    """
                    UPDATE Productos
                    SET
                        Nombre = @Nombre,
                        Descripcion = @Descripcion,
                        Precio = @Precio,
                        Imagen = COALESCE(@Imagen, Imagen),
                        IdCategoria = @IdCategoria,
                        Stock = @CantidadDisponible,
                        Estado = @Estado
                    WHERE IdProducto = @IdProducto;
                    """,
                    conn,
                    (SqlTransaction)transaction)
                {
                    CommandType = CommandType.Text
                };

                AddProductParameters(updateProductCommand, request);
                updateProductCommand.Parameters.Add("@IdProducto", SqlDbType.Int).Value = request.IdProducto;
                updateProductCommand.Parameters.Add("@Estado", SqlDbType.VarChar, 20).Value = request.Estado;

                var affectedProducts = await updateProductCommand.ExecuteNonQueryAsync();
                if (affectedProducts == 0)
                {
                    await transaction.RollbackAsync();
                    return new OperacionResponseDto
                    {
                        Codigo = 0,
                        Mensaje = "Producto no encontrado."
                    };
                }

                await using var updateInventoryCommand = new SqlCommand(
                    """
                    UPDATE Inventario
                    SET
                        CantidadDisponible = @CantidadDisponible,
                        CantidadMinima = @CantidadMinima,
                        FechaActualizacion = GETDATE()
                    WHERE IdProducto = @IdProducto;

                    IF @@ROWCOUNT = 0
                    BEGIN
                        INSERT INTO Inventario
                            (IdProducto, CantidadDisponible, CantidadMinima)
                        VALUES
                            (@IdProducto, @CantidadDisponible, @CantidadMinima);
                    END
                    """,
                    conn,
                    (SqlTransaction)transaction)
                {
                    CommandType = CommandType.Text
                };

                updateInventoryCommand.Parameters.Add("@IdProducto", SqlDbType.Int).Value = request.IdProducto;
                updateInventoryCommand.Parameters.Add("@CantidadDisponible", SqlDbType.Int).Value = request.CantidadDisponible;
                updateInventoryCommand.Parameters.Add("@CantidadMinima", SqlDbType.Int).Value = request.CantidadMinima;

                await updateInventoryCommand.ExecuteNonQueryAsync();
                await transaction.CommitAsync();

                return new OperacionResponseDto
                {
                    Codigo = 1,
                    Mensaje = "Producto actualizado exitosamente.",
                    IdProducto = request.IdProducto
                };
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        public async Task<OperacionResponseDto> EliminarProductoAsync(int idProducto)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand(
                """
                UPDATE Productos
                SET Estado = 'Inactivo'
                WHERE IdProducto = @IdProducto;
                """,
                conn)
            {
                CommandType = CommandType.Text
            };

            cmd.Parameters.Add("@IdProducto", SqlDbType.Int).Value = idProducto;

            await conn.OpenAsync();
            var affectedProducts = await cmd.ExecuteNonQueryAsync();

            if (affectedProducts == 0)
            {
                return new OperacionResponseDto
                {
                    Codigo = 0,
                    Mensaje = "Producto no encontrado."
                };
            }

            return new OperacionResponseDto
            {
                Codigo = 1,
                Mensaje = "Producto eliminado exitosamente.",
                IdProducto = idProducto
            };
        }

        private static SqlCommand CreateCatalogQueryCommand(SqlConnection conn, CatalogoProductoQuery query)
        {
            var cmd = new SqlCommand(
                """
                SELECT
                    p.IdProducto,
                    p.Nombre,
                    ISNULL(CONVERT(NVARCHAR(MAX), p.Descripcion), '') AS Descripcion,
                    p.Precio,
                    ISNULL(p.Imagen, '') AS Imagen,
                    p.IdCategoria,
                    c.NombreCategoria,
                    COALESCE(i.CantidadDisponible, p.Stock, 0) AS Stock,
                    CASE
                        WHEN COALESCE(i.CantidadDisponible, p.Stock, 0) <= 0 THEN 'Agotado'
                        ELSE 'Disponible'
                    END AS Disponibilidad
                FROM Productos p
                INNER JOIN Categorias c ON c.IdCategoria = p.IdCategoria
                LEFT JOIN Inventario i ON i.IdProducto = p.IdProducto
                WHERE p.Estado = 'Activo'
                    AND (@Busqueda IS NULL
                        OR p.Nombre LIKE @BusquedaPattern ESCAPE '\'
                        OR CONVERT(NVARCHAR(MAX), p.Descripcion) LIKE @BusquedaPattern ESCAPE '\'
                        OR c.NombreCategoria LIKE @BusquedaPattern ESCAPE '\')
                    AND (@IdCategoria IS NULL OR p.IdCategoria = @IdCategoria)
                    AND (@IdProducto IS NULL OR p.IdProducto = @IdProducto)
                ORDER BY
                    CASE WHEN @OrdenarPor = 'precio' AND @DireccionOrden = 'asc' THEN p.Precio END ASC,
                    CASE WHEN @OrdenarPor = 'precio' AND @DireccionOrden = 'desc' THEN p.Precio END DESC,
                    p.IdProducto DESC
                """,
                conn)
            {
                CommandType = CommandType.Text
            };

            AddCatalogQueryParameters(cmd, query);
            return cmd;
        }

        private static void AddCatalogQueryParameters(SqlCommand cmd, CatalogoProductoQuery query)
        {
            var searchTerm = query.NormalizedSearchTerm;
            var searchPattern = searchTerm is null ? null : $"%{EscapeLikeValue(searchTerm)}%";

            cmd.Parameters.Add("@Busqueda", SqlDbType.NVarChar, 255).Value =
                searchTerm is null ? DBNull.Value : searchTerm;
            cmd.Parameters.Add("@BusquedaPattern", SqlDbType.NVarChar, -1).Value =
                searchPattern is null ? DBNull.Value : searchPattern;
            cmd.Parameters.Add("@IdCategoria", SqlDbType.Int).Value =
                query.HasCategoryFilter ? query.IdCategoria!.Value : DBNull.Value;
            cmd.Parameters.Add("@IdProducto", SqlDbType.Int).Value = DBNull.Value;
            cmd.Parameters.Add("@OrdenarPor", SqlDbType.NVarChar, 20).Value =
                query.NormalizedSortField is null ? DBNull.Value : query.NormalizedSortField;
            cmd.Parameters.Add("@DireccionOrden", SqlDbType.NVarChar, 10).Value =
                query.NormalizedSortDirection;
        }

        private static string EscapeLikeValue(string value)
        {
            return value
                .Replace(@"\", @"\\")
                .Replace("%", @"\%")
                .Replace("_", @"\_")
                .Replace("[", @"\[");
        }

        private static void AddProductParameters(SqlCommand cmd, CreateProductoRequest request)
        {
            cmd.Parameters.Add("@Nombre", SqlDbType.VarChar, 150).Value = request.Nombre;
            cmd.Parameters.Add("@Descripcion", SqlDbType.VarChar, -1).Value = request.Descripcion;
            cmd.Parameters.Add("@Precio", SqlDbType.Decimal).Value = request.Precio;
            cmd.Parameters.Add("@Imagen", SqlDbType.VarChar, 255).Value = request.Imagen;
            cmd.Parameters.Add("@IdCategoria", SqlDbType.Int).Value = request.IdCategoria;
            cmd.Parameters.Add("@CantidadDisponible", SqlDbType.Int).Value = request.CantidadDisponible;
            cmd.Parameters.Add("@CantidadMinima", SqlDbType.Int).Value = request.CantidadMinima;
        }

        private static void AddProductParameters(SqlCommand cmd, UpdateProductoRequest request)
        {
            cmd.Parameters.Add("@Nombre", SqlDbType.VarChar, 150).Value = request.Nombre;
            cmd.Parameters.Add("@Descripcion", SqlDbType.VarChar, -1).Value = request.Descripcion;
            cmd.Parameters.Add("@Precio", SqlDbType.Decimal).Value = request.Precio;
            cmd.Parameters.Add("@Imagen", SqlDbType.VarChar, 255).Value =
                string.IsNullOrWhiteSpace(request.Imagen) ? DBNull.Value : request.Imagen;
            cmd.Parameters.Add("@IdCategoria", SqlDbType.Int).Value = request.IdCategoria;
            cmd.Parameters.Add("@CantidadDisponible", SqlDbType.Int).Value = request.CantidadDisponible;
            cmd.Parameters.Add("@CantidadMinima", SqlDbType.Int).Value = request.CantidadMinima;
        }

        private static CatalogoProductoResponseDto MapCatalogProduct(SqlDataReader reader)
        {
            return new CatalogoProductoResponseDto
            {
                IdProducto = GetInt32(reader, "IdProducto"),
                Nombre = GetString(reader, "Nombre"),
                Descripcion = GetString(reader, "Descripcion"),
                Precio = GetDecimal(reader, "Precio"),
                Imagen = GetString(reader, "Imagen"),
                IdCategoria = GetInt32(reader, "IdCategoria"),
                NombreCategoria = GetString(reader, "NombreCategoria"),
                Stock = GetInt32(reader, "Stock"),
                Disponibilidad = GetString(reader, "Disponibilidad")
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
            if (!TryGetOrdinal(reader, columnName, out var ordinal) || reader.IsDBNull(ordinal))
                return null;

            return reader.GetInt32(ordinal);
        }

        private static decimal GetDecimal(SqlDataReader reader, string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? 0 : reader.GetDecimal(ordinal);
        }

        private static bool TryGetOrdinal(SqlDataReader reader, string columnName, out int ordinal)
        {
            for (var index = 0; index < reader.FieldCount; index++)
            {
                if (string.Equals(reader.GetName(index), columnName, StringComparison.OrdinalIgnoreCase))
                {
                    ordinal = index;
                    return true;
                }
            }

            ordinal = -1;
            return false;
        }
    }
}

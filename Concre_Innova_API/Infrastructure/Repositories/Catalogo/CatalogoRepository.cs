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

        public async Task<IEnumerable<CatalogoProductoResponseDto>> ObtenerProductosRelacionadosAsync(
            int idProducto,
            int limite)
        {
            var productos = new List<CatalogoProductoResponseDto>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = CreateRelatedProductsCommand(conn, idProducto, limite);

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                productos.Add(MapCatalogProduct(reader));
            }

            return productos;
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
                        (Nombre, Descripcion, Precio, Stock, Imagen, Estado, IdCategoria, Tamano, Material)
                    OUTPUT INSERTED.IdProducto
                    VALUES
                        (@Nombre, @Descripcion, @Precio, @CantidadDisponible, @Imagen, 'Activo', @IdCategoria, @Tamano, @Material);
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
                        Tamano = COALESCE(@Tamano, Tamano),
                        Material = COALESCE(@Material, Material),
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
                    ISNULL(p.Tamano, '') AS Tamano,
                    ISNULL(p.Material, '') AS Material,
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
                        OR p.Nombre COLLATE Latin1_General_CI_AI LIKE @BusquedaPattern ESCAPE '\'
                        OR CONVERT(NVARCHAR(MAX), p.Descripcion) COLLATE Latin1_General_CI_AI LIKE @BusquedaPattern ESCAPE '\'
                        OR p.Tamano COLLATE Latin1_General_CI_AI LIKE @BusquedaPattern ESCAPE '\'
                        OR p.Material COLLATE Latin1_General_CI_AI LIKE @BusquedaPattern ESCAPE '\'
                        OR c.NombreCategoria COLLATE Latin1_General_CI_AI LIKE @BusquedaPattern ESCAPE '\')
                    AND (@IdCategoria IS NULL OR p.IdCategoria = @IdCategoria)
                    AND (@PrecioMinimo IS NULL OR p.Precio >= @PrecioMinimo)
                    AND (@PrecioMaximo IS NULL OR p.Precio <= @PrecioMaximo)
                    AND (@Disponibilidad IS NULL
                        OR (@Disponibilidad = 'disponible' AND COALESCE(i.CantidadDisponible, p.Stock, 0) > 0)
                        OR (@Disponibilidad = 'agotado' AND COALESCE(i.CantidadDisponible, p.Stock, 0) <= 0))
                    AND (@Tamano IS NULL
                        OR p.Tamano COLLATE Latin1_General_CI_AI = @Tamano)
                    AND (@Material IS NULL
                        OR p.Material COLLATE Latin1_General_CI_AI = @Material)
                    AND (@Tipo IS NULL
                        OR p.Nombre COLLATE Latin1_General_CI_AI LIKE @TipoPattern ESCAPE '\'
                        OR CONVERT(NVARCHAR(MAX), p.Descripcion) COLLATE Latin1_General_CI_AI LIKE @TipoPattern ESCAPE '\'
                        OR c.NombreCategoria COLLATE Latin1_General_CI_AI LIKE @TipoPattern ESCAPE '\')
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

        private static SqlCommand CreateRelatedProductsCommand(
            SqlConnection conn,
            int productId,
            int limit)
        {
            var cmd = new SqlCommand(
                """
                DECLARE
                    @BaseCategoryId INT,
                    @BaseSize VARCHAR(80),
                    @BaseMaterial VARCHAR(80),
                    @BasePrice DECIMAL(18, 2);

                SELECT
                    @BaseCategoryId = p.IdCategoria,
                    @BaseSize = NULLIF(p.Tamano, 'No especificado'),
                    @BaseMaterial = NULLIF(p.Material, 'No especificado'),
                    @BasePrice = p.Precio
                FROM Productos p
                WHERE p.IdProducto = @IdProducto
                    AND p.Estado = 'Activo';

                SELECT TOP (@Limite)
                    p.IdProducto,
                    p.Nombre,
                    ISNULL(CONVERT(NVARCHAR(MAX), p.Descripcion), '') AS Descripcion,
                    p.Precio,
                    ISNULL(p.Imagen, '') AS Imagen,
                    p.IdCategoria,
                    c.NombreCategoria,
                    ISNULL(p.Tamano, '') AS Tamano,
                    ISNULL(p.Material, '') AS Material,
                    COALESCE(i.CantidadDisponible, p.Stock, 0) AS Stock,
                    CASE
                        WHEN COALESCE(i.CantidadDisponible, p.Stock, 0) <= 0 THEN 'Agotado'
                        ELSE 'Disponible'
                    END AS Disponibilidad
                FROM Productos p
                INNER JOIN Categorias c ON c.IdCategoria = p.IdCategoria
                LEFT JOIN Inventario i ON i.IdProducto = p.IdProducto
                WHERE p.Estado = 'Activo'
                    AND p.IdProducto <> @IdProducto
                    AND @BaseCategoryId IS NOT NULL
                    AND (
                        p.IdCategoria = @BaseCategoryId
                        OR (@BaseMaterial IS NOT NULL
                            AND p.Material COLLATE Latin1_General_CI_AI = @BaseMaterial)
                        OR (@BaseSize IS NOT NULL
                            AND p.Tamano COLLATE Latin1_General_CI_AI = @BaseSize)
                    )
                ORDER BY
                    (
                        CASE WHEN p.IdCategoria = @BaseCategoryId THEN 4 ELSE 0 END +
                        CASE WHEN @BaseMaterial IS NOT NULL
                            AND p.Material COLLATE Latin1_General_CI_AI = @BaseMaterial THEN 2 ELSE 0 END +
                        CASE WHEN @BaseSize IS NOT NULL
                            AND p.Tamano COLLATE Latin1_General_CI_AI = @BaseSize THEN 1 ELSE 0 END
                    ) DESC,
                    ABS(p.Precio - @BasePrice) ASC,
                    p.IdProducto DESC;
                """,
                conn)
            {
                CommandType = CommandType.Text
            };

            cmd.Parameters.Add("@IdProducto", SqlDbType.Int).Value = productId;
            cmd.Parameters.Add("@Limite", SqlDbType.Int).Value = limit;
            return cmd;
        }

        private static void AddCatalogQueryParameters(SqlCommand cmd, CatalogoProductoQuery query)
        {
            var searchTerm = query.NormalizedSearchTerm;
            var searchPattern = searchTerm is null ? null : $"%{EscapeLikeValue(searchTerm)}%";

            AddNullableTextParameter(cmd, "@Busqueda", searchTerm);
            AddNullableTextParameter(cmd, "@BusquedaPattern", searchPattern, -1);
            cmd.Parameters.Add("@IdCategoria", SqlDbType.Int).Value =
                query.HasCategoryFilter ? query.IdCategoria!.Value : DBNull.Value;
            AddNullableDecimalParameter(cmd, "@PrecioMinimo", query.NormalizedMinimumPrice);
            AddNullableDecimalParameter(cmd, "@PrecioMaximo", query.NormalizedMaximumPrice);
            AddNullableTextParameter(cmd, "@Disponibilidad", query.NormalizedAvailability, 20);
            AddNullableTextParameter(cmd, "@Tamano", query.NormalizedSize, 80);
            AddNullableTextParameter(cmd, "@Material", query.NormalizedMaterial, 80);
            AddTextFilterParameters(cmd, "@Tipo", "@TipoPattern", query.NormalizedType);
            cmd.Parameters.Add("@IdProducto", SqlDbType.Int).Value = DBNull.Value;
            AddNullableTextParameter(cmd, "@OrdenarPor", query.NormalizedSortField, 20);
            AddNullableTextParameter(cmd, "@DireccionOrden", query.NormalizedSortDirection, 10);
        }

        private static void AddTextFilterParameters(
            SqlCommand cmd,
            string valueParameterName,
            string patternParameterName,
            string? value)
        {
            var pattern = value is null ? null : $"%{EscapeLikeValue(value)}%";
            AddNullableTextParameter(cmd, valueParameterName, value);
            AddNullableTextParameter(cmd, patternParameterName, pattern, -1);
        }

        private static void AddNullableTextParameter(
            SqlCommand cmd,
            string parameterName,
            string? value,
            int size = 255)
        {
            cmd.Parameters.Add(parameterName, SqlDbType.NVarChar, size).Value =
                value is null ? DBNull.Value : value;
        }

        private static void AddNullableDecimalParameter(
            SqlCommand cmd,
            string parameterName,
            decimal? value)
        {
            var parameter = cmd.Parameters.Add(parameterName, SqlDbType.Decimal);
            parameter.Precision = 18;
            parameter.Scale = 2;
            parameter.Value = value.HasValue ? value.Value : (object)DBNull.Value;
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
            cmd.Parameters.Add("@Tamano", SqlDbType.VarChar, 80).Value = GetProductAttributeValue(request.Tamano);
            cmd.Parameters.Add("@Material", SqlDbType.VarChar, 80).Value = GetProductAttributeValue(request.Material);
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
            cmd.Parameters.Add("@Tamano", SqlDbType.VarChar, 80).Value = GetNullableProductAttributeValue(request.Tamano);
            cmd.Parameters.Add("@Material", SqlDbType.VarChar, 80).Value = GetNullableProductAttributeValue(request.Material);
            cmd.Parameters.Add("@CantidadDisponible", SqlDbType.Int).Value = request.CantidadDisponible;
            cmd.Parameters.Add("@CantidadMinima", SqlDbType.Int).Value = request.CantidadMinima;
        }

        private static string GetProductAttributeValue(string? value)
        {
            return string.IsNullOrWhiteSpace(value) ? "No especificado" : value.Trim();
        }

        private static object GetNullableProductAttributeValue(string? value)
        {
            return string.IsNullOrWhiteSpace(value) ? DBNull.Value : value.Trim();
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
                Tamano = GetString(reader, "Tamano"),
                Material = GetString(reader, "Material"),
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

        private static decimal GetDecimal(SqlDataReader reader, string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? 0 : reader.GetDecimal(ordinal);
        }
    }
}

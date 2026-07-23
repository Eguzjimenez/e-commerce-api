using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Favorites
{
    public class FavoriteRepository : IFavoriteRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public FavoriteRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<IEnumerable<CatalogoProductoResponseDto>> GetFavoritesAsync(int userId)
        {
            var favorites = new List<CatalogoProductoResponseDto>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand(
                """
                SELECT
                    p.IdProducto,
                    p.Nombre,
                    ISNULL(CONVERT(NVARCHAR(MAX), p.Descripcion), '') AS Descripcion,
                    p.Precio,
                    ISNULL(p.Imagen, '') AS Imagen,
                    p.IdCategoria,
                    c.NombreCategoria,
                    p.IdTipo,
                    ISNULL(t.NombreTipo, '') AS NombreTipo,
                    ISNULL(p.Tamano, '') AS Tamano,
                    ISNULL(p.Material, '') AS Material,
                    ISNULL(p.Caracteristicas, '') AS Caracteristicas,
                    ISNULL(p.Stock, 0) AS Stock,
                    CASE
                        WHEN ISNULL(p.Stock, 0) <= 0 THEN 'Agotado'
                        ELSE 'Disponible'
                    END AS Disponibilidad
                FROM Favoritos f
                INNER JOIN Productos p ON p.IdProducto = f.IdProducto
                INNER JOIN Categorias c ON c.IdCategoria = p.IdCategoria
                LEFT JOIN TiposProducto t ON t.IdTipo = p.IdTipo
                WHERE f.IdUsuario = @IdUsuario
                    AND p.Estado = 'Activo'
                ORDER BY f.FechaRegistro DESC;
                """,
                conn)
            {
                CommandType = CommandType.Text
            };

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = userId;

            await conn.OpenAsync();
            await using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
                favorites.Add(MapCatalogProduct(reader));

            return favorites;
        }

        public async Task<int> GetFavoriteCountAsync(int userId)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand(
                """
                SELECT COUNT(1)
                FROM Favoritos f
                INNER JOIN Productos p ON p.IdProducto = f.IdProducto
                WHERE f.IdUsuario = @IdUsuario
                    AND p.Estado = 'Activo';
                """,
                conn)
            {
                CommandType = CommandType.Text
            };

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = userId;

            await conn.OpenAsync();
            return Convert.ToInt32(await cmd.ExecuteScalarAsync());
        }

        public async Task<IEnumerable<int>> GetFavoriteProductIdsAsync(int userId)
        {
            var favoriteIds = new List<int>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand(
                """
                SELECT f.IdProducto
                FROM Favoritos f
                INNER JOIN Productos p ON p.IdProducto = f.IdProducto
                WHERE f.IdUsuario = @IdUsuario
                    AND p.Estado = 'Activo'
                ORDER BY f.FechaRegistro DESC;
                """,
                conn)
            {
                CommandType = CommandType.Text
            };

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = userId;

            await conn.OpenAsync();
            await using var reader = await cmd.ExecuteReaderAsync();

            while (await reader.ReadAsync())
                favoriteIds.Add(reader.GetInt32(reader.GetOrdinal("IdProducto")));

            return favoriteIds;
        }

        public async Task<OperacionResponseDto> AddFavoriteAsync(int userId, int productId)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand(
                """
                IF NOT EXISTS (
                    SELECT 1 FROM Productos WHERE IdProducto = @IdProducto AND Estado = 'Activo'
                )
                BEGIN
                    SELECT 0 AS Codigo, 'Producto no encontrado.' AS Mensaje;
                    RETURN;
                END;

                IF NOT EXISTS (
                    SELECT 1 FROM Favoritos WHERE IdUsuario = @IdUsuario AND IdProducto = @IdProducto
                )
                BEGIN
                    INSERT INTO Favoritos (IdUsuario, IdProducto)
                    VALUES (@IdUsuario, @IdProducto);
                END;

                SELECT 1 AS Codigo, 'Producto agregado a favoritos.' AS Mensaje;
                """,
                conn)
            {
                CommandType = CommandType.Text
            };

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = userId;
            cmd.Parameters.Add("@IdProducto", SqlDbType.Int).Value = productId;

            return await ExecuteOperationAsync(conn, cmd, productId);
        }

        public async Task<OperacionResponseDto> RemoveFavoriteAsync(int userId, int productId)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand(
                """
                DELETE FROM Favoritos
                WHERE IdUsuario = @IdUsuario
                    AND IdProducto = @IdProducto;

                SELECT 1 AS Codigo, 'Producto eliminado de favoritos.' AS Mensaje;
                """,
                conn)
            {
                CommandType = CommandType.Text
            };

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = userId;
            cmd.Parameters.Add("@IdProducto", SqlDbType.Int).Value = productId;

            return await ExecuteOperationAsync(conn, cmd, productId);
        }

        private static async Task<OperacionResponseDto> ExecuteOperationAsync(
            SqlConnection conn,
            SqlCommand cmd,
            int productId)
        {
            await conn.OpenAsync();
            await using var reader = await cmd.ExecuteReaderAsync();

            if (!await reader.ReadAsync())
            {
                return new OperacionResponseDto
                {
                    Codigo = 0,
                    Mensaje = "No se pudo procesar la operacion."
                };
            }

            return new OperacionResponseDto
            {
                Codigo = reader.GetInt32(reader.GetOrdinal("Codigo")),
                Mensaje = reader.GetString(reader.GetOrdinal("Mensaje")),
                IdProducto = productId
            };
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
                IdTipo = GetNullableInt32(reader, "IdTipo"),
                NombreTipo = GetString(reader, "NombreTipo"),
                Tamano = GetString(reader, "Tamano"),
                Material = GetString(reader, "Material"),
                Caracteristicas = GetString(reader, "Caracteristicas"),
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
            return reader.GetInt32(reader.GetOrdinal(columnName));
        }

        private static int? GetNullableInt32(SqlDataReader reader, string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? null : reader.GetInt32(ordinal);
        }

        private static decimal GetDecimal(SqlDataReader reader, string columnName)
        {
            return reader.GetDecimal(reader.GetOrdinal(columnName));
        }
    }
}

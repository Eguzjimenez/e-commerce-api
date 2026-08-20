using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Inventario
{
    public class InventarioRepository : IInventarioRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public InventarioRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<PaginatedResponseDto<InventarioItemResponseDto>> BuscarAsync(
            InventarioQuery query,
            PaginationQuery pagination,
            CancellationToken cancellationToken)
        {
            var items = new List<InventarioItemResponseDto>();
            var totalItems = 0;

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerInventario", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@Busqueda", SqlDbType.NVarChar, 120).Value =
                (object?)NullIfEmpty(query.Busqueda) ?? DBNull.Value;
            cmd.Parameters.Add("@IdCategoria", SqlDbType.Int).Value =
                query.IdCategoria.HasValue && query.IdCategoria.Value > 0
                    ? query.IdCategoria.Value
                    : DBNull.Value;
            cmd.Parameters.Add("@Estado", SqlDbType.VarChar, 20).Value =
                (object?)NullIfEmpty(query.Estado) ?? DBNull.Value;
            cmd.Parameters.Add("@Pagina", SqlDbType.Int).Value = pagination.PageNumber;
            cmd.Parameters.Add("@TamanoPagina", SqlDbType.Int).Value = pagination.PageSize;

            await conn.OpenAsync(cancellationToken);

            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
            while (await reader.ReadAsync(cancellationToken))
            {
                items.Add(MapItem(reader));
                totalItems = GetInt32(reader, "TotalItems");
            }

            return new PaginatedResponseDto<InventarioItemResponseDto>
            {
                Items = items,
                TotalItems = totalItems,
                PageNumber = pagination.PageNumber,
                PageSize = pagination.PageSize
            };
        }

        public async Task<InventarioDetalleResponseDto?> ObtenerDetalleAsync(
            int idProducto,
            CancellationToken cancellationToken)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerInventarioDetalle", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdProducto", SqlDbType.Int).Value = idProducto;

            await conn.OpenAsync(cancellationToken);

            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

            if (!await reader.ReadAsync(cancellationToken))
            {
                return null;
            }

            var detalle = new InventarioDetalleResponseDto
            {
                IdProducto = GetInt32(reader, "IdProducto"),
                Nombre = GetString(reader, "Nombre"),
                Descripcion = GetString(reader, "Descripcion"),
                EstadoProducto = GetString(reader, "EstadoProducto"),
                Precio = GetDecimal(reader, "Precio"),
                Imagen = GetString(reader, "Imagen"),
                Tamano = GetString(reader, "Tamano"),
                Material = GetString(reader, "Material"),
                Caracteristicas = GetString(reader, "Caracteristicas"),
                IdCategoria = GetNullableInt32(reader, "IdCategoria"),
                NombreCategoria = GetString(reader, "NombreCategoria"),
                NombreTipo = GetString(reader, "NombreTipo"),
                CantidadDisponible = GetInt32(reader, "CantidadDisponible"),
                CantidadMinima = GetInt32(reader, "CantidadMinima"),
                FechaActualizacion = GetNullableDateTime(reader, "FechaActualizacion")
            };

            var variantes = new List<InventarioVarianteResponseDto>();

            if (await reader.NextResultAsync(cancellationToken))
            {
                while (await reader.ReadAsync(cancellationToken))
                {
                    variantes.Add(new InventarioVarianteResponseDto
                    {
                        IdVariante = GetInt32(reader, "IdVariante"),
                        NombreVariante = GetString(reader, "NombreVariante"),
                        Tamano = GetString(reader, "Tamano"),
                        Material = GetString(reader, "Material"),
                        Precio = GetDecimal(reader, "Precio"),
                        Stock = GetInt32(reader, "Stock"),
                        Estado = GetString(reader, "Estado")
                    });
                }
            }

            detalle.Variantes = variantes;
            return detalle;
        }

        public async Task<OperacionResponseDto> ActualizarAsync(
            ActualizarInventarioRequest request,
            int idUsuario,
            CancellationToken cancellationToken)
        {
            var resultado = new OperacionResponseDto { IdProducto = request.IdProducto };

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ActualizarInventario", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdProducto", SqlDbType.Int).Value = request.IdProducto;
            cmd.Parameters.Add("@CantidadDisponible", SqlDbType.Int).Value = request.CantidadDisponible;
            cmd.Parameters.Add("@CantidadMinima", SqlDbType.Int).Value = request.CantidadMinima;
            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;

            await conn.OpenAsync(cancellationToken);

            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
            if (await reader.ReadAsync(cancellationToken))
            {
                resultado.Codigo = GetInt32(reader, "Codigo");
                resultado.Mensaje = GetString(reader, "Mensaje") ?? string.Empty;
            }

            return resultado;
        }

        private static InventarioItemResponseDto MapItem(SqlDataReader reader)
        {
            return new InventarioItemResponseDto
            {
                IdProducto = GetInt32(reader, "IdProducto"),
                Nombre = GetString(reader, "Nombre"),
                EstadoProducto = GetString(reader, "EstadoProducto"),
                Precio = GetDecimal(reader, "Precio"),
                Imagen = GetString(reader, "Imagen"),
                IdCategoria = GetNullableInt32(reader, "IdCategoria"),
                NombreCategoria = GetString(reader, "NombreCategoria"),
                CantidadDisponible = GetInt32(reader, "CantidadDisponible"),
                CantidadMinima = GetInt32(reader, "CantidadMinima"),
                FechaActualizacion = GetNullableDateTime(reader, "FechaActualizacion"),
                TotalVariantes = GetInt32(reader, "TotalVariantes"),
                EstadoExistencias = GetString(reader, "EstadoExistencias")
            };
        }

        private static string? NullIfEmpty(string? value) =>
            string.IsNullOrWhiteSpace(value) ? null : value.Trim();

        private static int GetInt32(SqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? 0 : reader.GetInt32(ordinal);
        }

        private static int? GetNullableInt32(SqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? null : reader.GetInt32(ordinal);
        }

        private static decimal GetDecimal(SqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? 0m : reader.GetDecimal(ordinal);
        }

        private static string? GetString(SqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? null : reader.GetString(ordinal);
        }

        private static DateTime? GetNullableDateTime(SqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? null : reader.GetDateTime(ordinal);
        }
    }
}

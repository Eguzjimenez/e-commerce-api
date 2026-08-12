using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Models;
using Concre_Innova_API.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Visualizaciones
{
    public class VisualizacionRepository : IVisualizacionRepository
    {
        private const string ProductosTableTypeName = "TVP_VisualizacionProducto";

        private readonly ISqlConnectionFactory _connectionFactory;

        public VisualizacionRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<VisualizacionGuardada> GuardarAsync(
            int idUsuario,
            GuardarVisualizacionRequest request,
            CancellationToken cancellationToken)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_GuardarVisualizacion", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;
            cmd.Parameters.Add("@IdVisualizacion", SqlDbType.Int).Value =
                request.IdVisualizacion.HasValue && request.IdVisualizacion.Value > 0
                    ? request.IdVisualizacion.Value
                    : DBNull.Value;
            cmd.Parameters.Add("@Nombre", SqlDbType.VarChar, 120).Value = request.Nombre.Trim();
            cmd.Parameters.Add("@RutaImagenEspacio", SqlDbType.VarChar, 255).Value =
                request.RutaImagenEspacio.Trim();
            cmd.Parameters.Add("@AnchoLienzo", SqlDbType.Int).Value = request.AnchoLienzo;
            cmd.Parameters.Add("@AltoLienzo", SqlDbType.Int).Value = request.AltoLienzo;
            cmd.Parameters.Add(CreateProductsParameter(request.Productos));

            await conn.OpenAsync(cancellationToken);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

            if (!await reader.ReadAsync(cancellationToken))
            {
                return new VisualizacionGuardada
                {
                    Exitoso = false,
                    Mensaje = "SIN_RESPUESTA"
                };
            }

            return new VisualizacionGuardada
            {
                Exitoso = GetInt32(reader, "Codigo") == 1,
                Mensaje = GetString(reader, "Mensaje"),
                IdVisualizacion = GetNullableInt32(reader, "IdVisualizacion"),
                RutaImagenAnterior = GetNullableString(reader, "RutaImagenAnterior")
            };
        }

        public async Task<IReadOnlyList<VisualizacionResponseDto>> ObtenerPorUsuarioAsync(
            int idUsuario,
            int? idVisualizacion,
            CancellationToken cancellationToken)
        {
            var visualizacionesOrdenadas = new List<VisualizacionResponseDto>();
            var visualizacionesPorId = new Dictionary<int, VisualizacionResponseDto>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerVisualizacionesUsuario", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;
            cmd.Parameters.Add("@IdVisualizacion", SqlDbType.Int).Value =
                idVisualizacion.HasValue ? idVisualizacion.Value : DBNull.Value;

            await conn.OpenAsync(cancellationToken);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

            while (await reader.ReadAsync(cancellationToken))
            {
                var visualizacion = MapVisualizacion(reader);
                visualizacionesOrdenadas.Add(visualizacion);
                visualizacionesPorId[visualizacion.IdVisualizacion] = visualizacion;
            }

            if (await reader.NextResultAsync(cancellationToken))
            {
                while (await reader.ReadAsync(cancellationToken))
                {
                    var idVisualizacionProducto = GetInt32(reader, "IdVisualizacion");

                    if (visualizacionesPorId.TryGetValue(idVisualizacionProducto, out var visualizacion))
                    {
                        visualizacion.Productos.Add(MapProducto(reader));
                    }
                }
            }

            return visualizacionesOrdenadas;
        }

        public async Task<(bool Eliminada, string? RutaImagenEspacio)> EliminarAsync(
            int idUsuario,
            int idVisualizacion,
            CancellationToken cancellationToken)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_EliminarVisualizacion", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;
            cmd.Parameters.Add("@IdVisualizacion", SqlDbType.Int).Value = idVisualizacion;

            await conn.OpenAsync(cancellationToken);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

            if (!await reader.ReadAsync(cancellationToken))
                return (false, null);

            var eliminada = GetInt32(reader, "Codigo") == 1;

            return (eliminada, eliminada ? GetNullableString(reader, "RutaImagenEspacio") : null);
        }

        private static SqlParameter CreateProductsParameter(
            IReadOnlyCollection<VisualizacionProductoRequestDto> productos)
        {
            var productosTable = new DataTable();
            productosTable.Columns.Add("IdProducto", typeof(int));
            productosTable.Columns.Add("IdVariante", typeof(int));
            productosTable.Columns.Add("Cantidad", typeof(int));
            productosTable.Columns.Add("Color", typeof(string));
            productosTable.Columns.Add("Macetero", typeof(string));
            productosTable.Columns.Add("PosicionX", typeof(decimal));
            productosTable.Columns.Add("PosicionY", typeof(decimal));
            productosTable.Columns.Add("Ancho", typeof(decimal));
            productosTable.Columns.Add("Alto", typeof(decimal));
            productosTable.Columns.Add("Rotacion", typeof(decimal));
            productosTable.Columns.Add("Orden", typeof(int));

            var orden = 1;

            foreach (var producto in productos)
            {
                productosTable.Rows.Add(
                    producto.IdProducto,
                    producto.IdVariante.HasValue && producto.IdVariante.Value > 0
                        ? producto.IdVariante.Value
                        : DBNull.Value,
                    producto.Cantidad,
                    producto.Color ?? string.Empty,
                    producto.Macetero ?? string.Empty,
                    producto.PosicionX,
                    producto.PosicionY,
                    producto.Ancho,
                    producto.Alto,
                    producto.Rotacion,
                    producto.Orden > 0 ? producto.Orden : orden);

                orden++;
            }

            return new SqlParameter("@Productos", productosTable)
            {
                SqlDbType = SqlDbType.Structured,
                TypeName = ProductosTableTypeName
            };
        }

        private static VisualizacionResponseDto MapVisualizacion(SqlDataReader reader)
        {
            return new VisualizacionResponseDto
            {
                IdVisualizacion = GetInt32(reader, "IdVisualizacion"),
                Nombre = GetString(reader, "Nombre"),
                RutaImagenEspacio = GetString(reader, "RutaImagenEspacio"),
                AnchoLienzo = GetInt32(reader, "AnchoLienzo"),
                AltoLienzo = GetInt32(reader, "AltoLienzo"),
                FechaCreacion = reader.GetDateTime(reader.GetOrdinal("FechaCreacion")),
                FechaActualizacion = reader.GetDateTime(reader.GetOrdinal("FechaActualizacion")),
                TotalProductos = GetInt32(reader, "TotalProductos")
            };
        }

        private static VisualizacionProductoResponseDto MapProducto(SqlDataReader reader)
        {
            return new VisualizacionProductoResponseDto
            {
                IdVisualizacionProducto = GetInt32(reader, "IdVisualizacionProducto"),
                IdProducto = GetInt32(reader, "IdProducto"),
                IdVariante = GetNullableInt32(reader, "IdVariante"),
                Nombre = GetString(reader, "Nombre"),
                Imagen = GetString(reader, "Imagen"),
                Precio = GetDecimal(reader, "Precio"),
                Tamano = GetString(reader, "Tamano"),
                Material = GetString(reader, "Material"),
                Clasificacion = GetString(reader, "Clasificacion"),
                Cantidad = GetInt32(reader, "Cantidad"),
                Color = GetString(reader, "Color"),
                Macetero = GetString(reader, "Macetero"),
                PosicionX = GetDecimal(reader, "PosicionX"),
                PosicionY = GetDecimal(reader, "PosicionY"),
                Ancho = GetDecimal(reader, "Ancho"),
                Alto = GetDecimal(reader, "Alto"),
                Rotacion = GetDecimal(reader, "Rotacion"),
                Orden = GetInt32(reader, "Orden")
            };
        }

        private static string GetString(SqlDataReader reader, string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? string.Empty : reader.GetString(ordinal);
        }

        private static string? GetNullableString(SqlDataReader reader, string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? null : reader.GetString(ordinal);
        }

        private static int GetInt32(SqlDataReader reader, string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? 0 : reader.GetInt32(ordinal);
        }

        private static int? GetNullableInt32(SqlDataReader reader, string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? null : reader.GetInt32(ordinal);
        }

        private static decimal GetDecimal(SqlDataReader reader, string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? 0 : reader.GetDecimal(ordinal);
        }
    }
}

using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Asesor
{
    public class AsesorRepository : IAsesorRepository
    {
        private const string OpcionesTableTypeName = "TVP_AsesorOpcion";

        private readonly ISqlConnectionFactory _connectionFactory;

        public AsesorRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<AsesorCuestionarioResponseDto> ObtenerCuestionarioAsync(
            CancellationToken cancellationToken)
        {
            var preguntasOrdenadas = new List<AsesorPreguntaResponseDto>();
            var preguntasPorId = new Dictionary<int, AsesorPreguntaResponseDto>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerCuestionarioAsesor", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            await conn.OpenAsync(cancellationToken);

            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

            while (await reader.ReadAsync(cancellationToken))
            {
                var pregunta = MapPregunta(reader);
                preguntasOrdenadas.Add(pregunta);
                preguntasPorId[pregunta.IdPregunta] = pregunta;
            }

            if (await reader.NextResultAsync(cancellationToken))
            {
                while (await reader.ReadAsync(cancellationToken))
                {
                    var opcion = MapOpcion(reader);

                    if (preguntasPorId.TryGetValue(opcion.IdPregunta, out var pregunta))
                        pregunta.Opciones.Add(opcion);
                }
            }

            return new AsesorCuestionarioResponseDto
            {
                Preguntas = preguntasOrdenadas
            };
        }

        public async Task<IReadOnlyList<AsesorProductoRecomendadoResponseDto>>
            GenerarRecomendacionesAsync(
                IReadOnlyCollection<int> idsOpcionSeleccionados,
                int limitePorClasificacion,
                CancellationToken cancellationToken)
        {
            var productos = new List<AsesorProductoRecomendadoResponseDto>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_GenerarRecomendacionesAsesor", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add(CreateOptionsParameter(idsOpcionSeleccionados));
            cmd.Parameters.Add("@LimitePorClasificacion", SqlDbType.Int).Value =
                limitePorClasificacion;

            await conn.OpenAsync(cancellationToken);

            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
            while (await reader.ReadAsync(cancellationToken))
            {
                productos.Add(MapProductoRecomendado(reader));
            }

            return productos;
        }

        public async Task<bool> GuardarRespuestasAsync(
            int idUsuario,
            IReadOnlyCollection<int> idsOpcionSeleccionados,
            CancellationToken cancellationToken)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_GuardarRespuestasAsesor", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;
            cmd.Parameters.Add(CreateOptionsParameter(idsOpcionSeleccionados));

            await conn.OpenAsync(cancellationToken);

            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

            return await reader.ReadAsync(cancellationToken) &&
                   reader.GetInt32(reader.GetOrdinal("Codigo")) == 1;
        }

        public async Task LimpiarRespuestasAsync(int idUsuario, CancellationToken cancellationToken)
        {
            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_LimpiarRespuestasAsesor", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;

            await conn.OpenAsync(cancellationToken);
            await cmd.ExecuteNonQueryAsync(cancellationToken);
        }

        private static SqlParameter CreateOptionsParameter(IReadOnlyCollection<int> idsOpcion)
        {
            var opcionesTable = new DataTable();
            opcionesTable.Columns.Add("IdOpcion", typeof(int));

            foreach (var idOpcion in idsOpcion)
            {
                opcionesTable.Rows.Add(idOpcion);
            }

            return new SqlParameter("@Opciones", opcionesTable)
            {
                SqlDbType = SqlDbType.Structured,
                TypeName = OpcionesTableTypeName
            };
        }

        private static AsesorPreguntaResponseDto MapPregunta(SqlDataReader reader)
        {
            return new AsesorPreguntaResponseDto
            {
                IdPregunta = GetInt32(reader, "IdPregunta"),
                Codigo = GetString(reader, "Codigo"),
                Texto = GetString(reader, "Texto"),
                Ayuda = GetString(reader, "Ayuda"),
                Orden = GetInt32(reader, "Orden")
            };
        }

        private static AsesorOpcionResponseDto MapOpcion(SqlDataReader reader)
        {
            return new AsesorOpcionResponseDto
            {
                IdOpcion = GetInt32(reader, "IdOpcion"),
                IdPregunta = GetInt32(reader, "IdPregunta"),
                Codigo = GetString(reader, "Codigo"),
                Etiqueta = GetString(reader, "Etiqueta"),
                Descripcion = GetString(reader, "Descripcion"),
                Orden = GetInt32(reader, "Orden")
            };
        }

        private static AsesorProductoRecomendadoResponseDto MapProductoRecomendado(
            SqlDataReader reader)
        {
            return new AsesorProductoRecomendadoResponseDto
            {
                IdProducto = GetInt32(reader, "IdProducto"),
                Nombre = GetString(reader, "Nombre"),
                Descripcion = GetString(reader, "Descripcion"),
                Precio = GetDecimal(reader, "Precio"),
                Imagen = GetString(reader, "Imagen"),
                IdCategoria = GetInt32(reader, "IdCategoria"),
                NombreCategoria = GetString(reader, "NombreCategoria"),
                NombreTipo = GetString(reader, "NombreTipo"),
                Tamano = GetString(reader, "Tamano"),
                Material = GetString(reader, "Material"),
                Stock = GetInt32(reader, "Stock"),
                Clasificacion = GetString(reader, "Clasificacion"),
                Puntaje = GetInt32(reader, "Puntaje")
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

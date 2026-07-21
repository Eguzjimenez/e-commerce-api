using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Infrastructure.Data;
using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Domain.Entities;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Bitacora
{
    public class BitacoraRepository : IBitacoraRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public BitacoraRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<IEnumerable<BitacoraResponseDto>> GetBitacoraAsync()
        {
            var list = new List<BitacoraResponseDto>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand(
                """
                SELECT
                    b.IdBitacora,
                    b.IdUsuario,
                    b.TablaAfectada,
                    b.Operacion,
                    b.Descripcion,
                    b.FechaHora,
                    b.IpUsuario,
                    ISNULL(u.Correo, '') AS Correo,
                    LTRIM(RTRIM(CONCAT(ISNULL(u.Nombre, ''), ' ', ISNULL(u.Apellido, '')))) AS NombreUsuario
                FROM Bitacora b
                LEFT JOIN Usuarios u ON u.IdUsuario = b.IdUsuario
                ORDER BY b.FechaHora DESC, b.IdBitacora DESC;
                """,
                conn)
            {
                CommandType = CommandType.Text
            };

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new BitacoraResponseDto
                {
                    IdBitacora    = reader.GetInt32(reader.GetOrdinal("IdBitacora")),
                    IdUsuario     = reader.IsDBNull(reader.GetOrdinal("IdUsuario")) ? null : reader.GetInt32(reader.GetOrdinal("IdUsuario")),
                    TablaAfectada = reader.IsDBNull(reader.GetOrdinal("TablaAfectada")) ? string.Empty : reader.GetString(reader.GetOrdinal("TablaAfectada")),
                    Operacion     = reader.IsDBNull(reader.GetOrdinal("Operacion"))     ? string.Empty : reader.GetString(reader.GetOrdinal("Operacion")),
                    Descripcion   = reader.IsDBNull(reader.GetOrdinal("Descripcion"))   ? string.Empty : reader.GetString(reader.GetOrdinal("Descripcion")),
                    FechaHora     = reader.GetDateTime(reader.GetOrdinal("FechaHora")),
                    IpUsuario     = reader.IsDBNull(reader.GetOrdinal("IpUsuario"))     ? string.Empty : reader.GetString(reader.GetOrdinal("IpUsuario")),
                    Correo = reader.IsDBNull(reader.GetOrdinal("Correo")) ? string.Empty : reader.GetString(reader.GetOrdinal("Correo")),
                    NombreUsuario = reader.IsDBNull(reader.GetOrdinal("NombreUsuario")) ? string.Empty : reader.GetString(reader.GetOrdinal("NombreUsuario")),

                });
            }

            return list;
        }

        public async Task<PaginatedResponseDto<BitacoraResponseDto>> GetBitacoraPaginadaAsync(
            PaginationQuery pagination,
            string? busqueda,
            string? operacion)
        {
            var list = new List<BitacoraResponseDto>();
            var totalItems = 0;
            var normalizedSearch = NormalizeText(busqueda);
            var normalizedOperation = NormalizeText(operacion);

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand(
                """
                SELECT
                    b.IdBitacora,
                    b.IdUsuario,
                    b.TablaAfectada,
                    b.Operacion,
                    b.Descripcion,
                    b.FechaHora,
                    b.IpUsuario,
                    ISNULL(u.Correo, '') AS Correo,
                    LTRIM(RTRIM(CONCAT(ISNULL(u.Nombre, ''), ' ', ISNULL(u.Apellido, '')))) AS NombreUsuario,
                    COUNT(1) OVER() AS TotalItems
                FROM Bitacora b
                LEFT JOIN Usuarios u ON u.IdUsuario = b.IdUsuario
                WHERE (@Busqueda IS NULL
                        OR ISNULL(u.Correo, '') COLLATE Latin1_General_CI_AI LIKE @BusquedaPattern ESCAPE '\'
                        OR LTRIM(RTRIM(CONCAT(ISNULL(u.Nombre, ''), ' ', ISNULL(u.Apellido, '')))) COLLATE Latin1_General_CI_AI LIKE @BusquedaPattern ESCAPE '\'
                        OR ISNULL(b.TablaAfectada, '') COLLATE Latin1_General_CI_AI LIKE @BusquedaPattern ESCAPE '\'
                        OR ISNULL(b.Descripcion, '') COLLATE Latin1_General_CI_AI LIKE @BusquedaPattern ESCAPE '\'
                        OR ISNULL(b.IpUsuario, '') COLLATE Latin1_General_CI_AI LIKE @BusquedaPattern ESCAPE '\')
                    AND (@Operacion IS NULL OR b.Operacion = @Operacion)
                ORDER BY b.FechaHora DESC, b.IdBitacora DESC
                OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
                """,
                conn)
            {
                CommandType = CommandType.Text
            };

            AddNullableTextParameter(cmd, "@Busqueda", normalizedSearch);
            AddNullableTextParameter(
                cmd,
                "@BusquedaPattern",
                normalizedSearch is null ? null : $"%{EscapeLikeValue(normalizedSearch)}%",
                -1);
            AddNullableTextParameter(cmd, "@Operacion", normalizedOperation, 60);
            cmd.Parameters.Add("@Offset", SqlDbType.Int).Value = pagination.Offset;
            cmd.Parameters.Add("@PageSize", SqlDbType.Int).Value = pagination.PageSize;

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapBitacora(reader));
                totalItems = reader.GetInt32(reader.GetOrdinal("TotalItems"));
            }

            return new PaginatedResponseDto<BitacoraResponseDto>
            {
                Items = list,
                TotalItems = totalItems,
                PageNumber = pagination.PageNumber,
                PageSize = pagination.PageSize
            };
        }

        public async Task<BitacoraResult> InsertBitacoraAsync(int idUsuario, string tablaAfectada, string operacion, string descripcion, string ipUsuario)
        {
            var result = new BitacoraResult();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_InsertarBitacora", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@IdUsuario", idUsuario);
            cmd.Parameters.AddWithValue("@TablaAfectada", tablaAfectada);
            cmd.Parameters.AddWithValue("@Operacion", operacion);
            cmd.Parameters.AddWithValue("@Descripcion", descripcion);
            cmd.Parameters.AddWithValue("@IpUsuario", ipUsuario);

            await conn.OpenAsync();

            try
            {
                await using var reader = await cmd.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    result.Codigo = reader.GetInt32(reader.GetOrdinal("Codigo"));
                    result.Mensaje = reader.GetString(reader.GetOrdinal("Mensaje"));

                    if (result.Codigo == 1 && !reader.IsDBNull(reader.GetOrdinal("IdBitacora")))
                        result.IdBitacora = reader.GetInt32(reader.GetOrdinal("IdBitacora"));
                }
            }
            catch (Exception ex)
            {
                result.Codigo = -1;
                result.Mensaje = ex.Message;
            }

            return result;
        }

        private static BitacoraResponseDto MapBitacora(SqlDataReader reader)
        {
            return new BitacoraResponseDto
            {
                IdBitacora = reader.GetInt32(reader.GetOrdinal("IdBitacora")),
                IdUsuario = reader.IsDBNull(reader.GetOrdinal("IdUsuario")) ? null : reader.GetInt32(reader.GetOrdinal("IdUsuario")),
                TablaAfectada = reader.IsDBNull(reader.GetOrdinal("TablaAfectada")) ? string.Empty : reader.GetString(reader.GetOrdinal("TablaAfectada")),
                Operacion = reader.IsDBNull(reader.GetOrdinal("Operacion")) ? string.Empty : reader.GetString(reader.GetOrdinal("Operacion")),
                Descripcion = reader.IsDBNull(reader.GetOrdinal("Descripcion")) ? string.Empty : reader.GetString(reader.GetOrdinal("Descripcion")),
                FechaHora = reader.GetDateTime(reader.GetOrdinal("FechaHora")),
                IpUsuario = reader.IsDBNull(reader.GetOrdinal("IpUsuario")) ? string.Empty : reader.GetString(reader.GetOrdinal("IpUsuario")),
                Correo = reader.IsDBNull(reader.GetOrdinal("Correo")) ? string.Empty : reader.GetString(reader.GetOrdinal("Correo")),
                NombreUsuario = reader.IsDBNull(reader.GetOrdinal("NombreUsuario")) ? string.Empty : reader.GetString(reader.GetOrdinal("NombreUsuario"))
            };
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

        private static string? NormalizeText(string? value)
        {
            return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
        }

        private static string EscapeLikeValue(string value)
        {
            return value
                .Replace(@"\", @"\\")
                .Replace("%", @"\%")
                .Replace("_", @"\_")
                .Replace("[", @"\[");
        }
    }
}

using Concre_Innova_API.Models.DTOs.Responses;
using Concre_Innova_API.Models.Entities;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Repositories.Bitacora
{
    public class BitacoraRepository : IBitacoraRepository
    {
        private readonly string _connectionString;

        public BitacoraRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection") ?? string.Empty;
        }

        public async Task<IEnumerable<BitacoraResponseDto>> GetBitacoraAsync()
        {
            var list = new List<BitacoraResponseDto>();

            await using var conn = new SqlConnection(_connectionString);
            await using var cmd = new SqlCommand(@"
                SELECT
                    b.IdBitacora,
                    b.IdUsuario,
                    b.TablaAfectada,
                    b.Operacion,
                    b.Descripcion,
                    b.FechaHora,
                    b.IpUsuario,
                    u.Correo,
                    CONCAT(u.Nombre, ' ', u.Apellido) AS NombreUsuario
                FROM Bitacora b
                INNER JOIN Usuarios u ON u.IdUsuario = b.IdUsuario
                ORDER BY b.FechaHora DESC, b.IdBitacora DESC;", conn)
            {
                CommandType = CommandType.Text
            };

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new BitacoraResponseDto
                {
                    IdBitacora = reader.GetInt32(reader.GetOrdinal("IdBitacora")),
                    IdUsuario = reader.GetInt32(reader.GetOrdinal("IdUsuario")),
                    TablaAfectada = reader.IsDBNull(reader.GetOrdinal("TablaAfectada")) ? string.Empty : reader.GetString(reader.GetOrdinal("TablaAfectada")),
                    Operacion = reader.IsDBNull(reader.GetOrdinal("Operacion")) ? string.Empty : reader.GetString(reader.GetOrdinal("Operacion")),
                    Descripcion = reader.IsDBNull(reader.GetOrdinal("Descripcion")) ? string.Empty : reader.GetString(reader.GetOrdinal("Descripcion")),
                    FechaHora = reader.IsDBNull(reader.GetOrdinal("FechaHora")) ? DateTime.MinValue : reader.GetDateTime(reader.GetOrdinal("FechaHora")),
                    IpUsuario = reader.IsDBNull(reader.GetOrdinal("IpUsuario")) ? string.Empty : reader.GetString(reader.GetOrdinal("IpUsuario")),
                    Correo = reader.IsDBNull(reader.GetOrdinal("Correo")) ? string.Empty : reader.GetString(reader.GetOrdinal("Correo")),
                    NombreUsuario = reader.IsDBNull(reader.GetOrdinal("NombreUsuario")) ? string.Empty : reader.GetString(reader.GetOrdinal("NombreUsuario"))
                });
            }

            return list;
        }

        public async Task<BitacoraResult> InsertBitacoraAsync(
            int idUsuario,
            string tablaAfectada,
            string operacion,
            string descripcion,
            string ipUsuario)
        {
            var result = new BitacoraResult();

            await using var conn = new SqlConnection(_connectionString);
            await using var cmd = new SqlCommand(@"
                INSERT INTO Bitacora
                    (IdUsuario, TablaAfectada, Operacion, Descripcion, FechaHora, IpUsuario)
                OUTPUT INSERTED.IdBitacora
                VALUES
                    (@IdUsuario, @TablaAfectada, @Operacion, @Descripcion, GETDATE(), @IpUsuario);", conn)
            {
                CommandType = CommandType.Text
            };

            cmd.Parameters.AddWithValue("@IdUsuario", idUsuario);
            cmd.Parameters.AddWithValue("@TablaAfectada", Truncate(tablaAfectada, 100));
            cmd.Parameters.AddWithValue("@Operacion", Truncate(operacion, 20));
            cmd.Parameters.AddWithValue("@Descripcion", Truncate(descripcion, 500));
            cmd.Parameters.AddWithValue("@IpUsuario", Truncate(ipUsuario, 50));

            await conn.OpenAsync();

            try
            {
                var insertedId = await cmd.ExecuteScalarAsync();
                result.Codigo = 1;
                result.Mensaje = "Bitacora registrada correctamente.";
                result.IdBitacora = insertedId == null ? null : Convert.ToInt32(insertedId);
            }
            catch (Exception ex)
            {
                result.Codigo = -1;
                result.Mensaje = ex.Message;
            }

            return result;
        }

        private static string Truncate(string value, int maxLength)
        {
            if (string.IsNullOrEmpty(value))
                return string.Empty;

            return value.Length <= maxLength ? value : value[..maxLength];
        }
    }
}

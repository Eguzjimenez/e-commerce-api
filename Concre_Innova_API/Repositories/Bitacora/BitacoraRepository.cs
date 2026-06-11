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
            await using var cmd = new SqlCommand("SP_ObtenerBitacora", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            await conn.OpenAsync();

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new BitacoraResponseDto
                {
                    IdBitacora    = reader.GetInt32(reader.GetOrdinal("IdBitacora")),
                    IdUsuario     = reader.GetInt32(reader.GetOrdinal("IdUsuario")),
                    TablaAfectada = reader.IsDBNull(reader.GetOrdinal("TablaAfectada")) ? string.Empty : reader.GetString(reader.GetOrdinal("TablaAfectada")),
                    Operacion     = reader.IsDBNull(reader.GetOrdinal("Operacion"))     ? string.Empty : reader.GetString(reader.GetOrdinal("Operacion")),
                    Descripcion   = reader.IsDBNull(reader.GetOrdinal("Descripcion"))   ? string.Empty : reader.GetString(reader.GetOrdinal("Descripcion")),
                    FechaHora     = reader.GetDateTime(reader.GetOrdinal("FechaHora")),
                    IpUsuario     = reader.IsDBNull(reader.GetOrdinal("IpUsuario"))     ? string.Empty : reader.GetString(reader.GetOrdinal("IpUsuario")),
                    Correo = reader.IsDBNull(reader.GetOrdinal("correo")) ? string.Empty : reader.GetString(reader.GetOrdinal("correo")),        
                    NombreUsuario = reader.IsDBNull(reader.GetOrdinal("nombreUsuario")) ? string.Empty : reader.GetString(reader.GetOrdinal("nombreUsuario")),  // ← agregar

                });
            }

            return list;
        }

        public async Task<BitacoraResult> InsertBitacoraAsync(int idUsuario, string tablaAfectada, string operacion, string descripcion, string ipUsuario)
        {
            var result = new BitacoraResult();

            await using var conn = new SqlConnection(_connectionString);
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
    }
}

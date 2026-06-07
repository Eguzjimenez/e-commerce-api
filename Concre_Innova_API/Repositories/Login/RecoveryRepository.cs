using Concre_Innova_API.Models.Entities;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Repositories.Login
{
    public class RecoveryRepository : IRecoveryRepository
    {
        private readonly string _connectionString;

        public RecoveryRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection") ?? string.Empty;
        }

        public async Task<UserLogin> ValidateEmailAsync(string correo)
        {
            var result = new UserLogin();

            await using var conn = new SqlConnection(_connectionString);
            await using var cmd = new SqlCommand("SP_ValidarCorreoRecuperacion", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@Correo", correo);

            await conn.OpenAsync();

            try
            {
                await using var reader = await cmd.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    result.Codigo = reader.GetInt32(reader.GetOrdinal("Codigo"));
                    result.Mensaje = reader.GetString(reader.GetOrdinal("Mensaje"));

                    if (result.Codigo == 1)
                    {
                        if (!reader.IsDBNull(reader.GetOrdinal("IdUsuario")))
                            result.IdUsuario = reader.GetInt32(reader.GetOrdinal("IdUsuario"));
                    }
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

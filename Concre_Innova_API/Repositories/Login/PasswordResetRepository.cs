using Concre_Innova_API.Models.Entities;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Repositories.Login
{
    public class PasswordResetRepository : IPasswordResetRepository
    {
        private readonly string _connectionString;

        public PasswordResetRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection") ?? string.Empty;
        }

        public async Task<UserLogin> ResetPasswordAsync(int idUsuario, string nuevaContrasena)
        {
            var result = new UserLogin();

            await using var conn = new SqlConnection(_connectionString);
            await using var cmd = new SqlCommand("SP_RestablecerContrasena", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@IdUsuario", idUsuario);
            cmd.Parameters.AddWithValue("@NuevaContrasena", nuevaContrasena);

            await conn.OpenAsync();

            try
            {
                await using var reader = await cmd.ExecuteReaderAsync();
                if (await reader.ReadAsync())
                {
                    result.Codigo = reader.GetInt32(reader.GetOrdinal("Codigo"));
                    result.Mensaje = reader.GetString(reader.GetOrdinal("Mensaje"));
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

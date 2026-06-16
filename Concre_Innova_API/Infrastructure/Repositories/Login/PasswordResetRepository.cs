using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Infrastructure.Data;
using Concre_Innova_API.Domain.Entities;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Login
{
    public class PasswordResetRepository : IPasswordResetRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public PasswordResetRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<UserLogin> ResetPasswordAsync(int idUsuario, string nuevaContrasena)
        {
            var result = new UserLogin();

            await using var conn = _connectionFactory.CreateConnection();
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

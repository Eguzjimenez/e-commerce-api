using Concre_Innova_API.Models.Entities;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Repositories.Login
{
    public class LoginRepository : ILoginRepository
    {
        private readonly string _connectionString;

        public LoginRepository(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection") ?? string.Empty;
        }

        public async Task<UserLogin> LoginAsync(string correo, string contrasena)
        {
            var result = new UserLogin();

            await using var conn = new SqlConnection(_connectionString);
            await using var cmd = new SqlCommand("SP_Login", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@Correo", correo);
            cmd.Parameters.AddWithValue("@Contrasena", contrasena);

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

                        if (!reader.IsDBNull(reader.GetOrdinal("IdRol")))
                            result.IdRol = reader.GetInt32(reader.GetOrdinal("IdRol"));
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

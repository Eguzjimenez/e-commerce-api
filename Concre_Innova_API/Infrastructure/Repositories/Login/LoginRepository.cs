using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Infrastructure.Data;
using Concre_Innova_API.Domain.Entities;
using Concre_Innova_API.Domain.Constants;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Login
{
    public class LoginRepository : ILoginRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public LoginRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<UserLogin> LoginAsync(string correo, string contrasena)
        {
            var result = new UserLogin();

            await using var conn = _connectionFactory.CreateConnection();
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

                        if (result.IdRol == AppRoles.Inactivo)
                        {
                            result.Codigo = 0;
                            result.Mensaje = "La cuenta se encuentra inactiva.";
                            result.IdUsuario = null;
                            result.IdRol = null;
                        }
                        else
                        {
                            result.NombreRol = AppRoles.GetName(result.IdRol);
                        }
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

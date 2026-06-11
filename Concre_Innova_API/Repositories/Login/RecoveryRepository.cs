using Concre_Innova_API.Models.Entities;
using Microsoft.Data.SqlClient;
using System.Collections.Concurrent;
using System.Data;

namespace Concre_Innova_API.Repositories.Login
{
    public class RecoveryRepository : IRecoveryRepository
    {
        private readonly string _connectionString;

        private static readonly ConcurrentDictionary<string, RecoveryTokenInfo> RecoveryTokens = new();

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

                    if (result.Codigo == 1 &&
                        !reader.IsDBNull(reader.GetOrdinal("IdUsuario")))
                    {
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

        public Task<UserLogin> GenerateRecoveryTokenAsync(int idUsuario, string correo)
        {
            var token = Guid.NewGuid().ToString("N");
            var expirationDate = DateTime.UtcNow.AddMinutes(15);

            RecoveryTokens[token] = new RecoveryTokenInfo
            {
                IdUsuario = idUsuario,
                Correo = correo.Trim(),
                ExpirationDate = expirationDate
            };

            var result = new UserLogin
            {
                Codigo = 1,
                Mensaje = $"Token generado correctamente. Enlace: http://localhost:5222/reset-password?token={token}",
                IdUsuario = idUsuario
            };

            return Task.FromResult(result);
        }

        public Task<UserLogin> ValidateRecoveryTokenAsync(string token)
        {
            var result = new UserLogin();

            if (string.IsNullOrWhiteSpace(token))
            {
                result.Codigo = 0;
                result.Mensaje = "El token de recuperacion es requerido.";
                return Task.FromResult(result);
            }

            if (!RecoveryTokens.TryGetValue(token, out var tokenInfo))
            {
                result.Codigo = 0;
                result.Mensaje = "El enlace de recuperacion no es valido.";
                return Task.FromResult(result);
            }

            if (tokenInfo.ExpirationDate < DateTime.UtcNow)
            {
                RecoveryTokens.TryRemove(token, out _);

                result.Codigo = 0;
                result.Mensaje = "El enlace de recuperacion ha expirado.";
                return Task.FromResult(result);
            }

            result.Codigo = 1;
            result.Mensaje = "El enlace de recuperacion es valido.";
            result.IdUsuario = tokenInfo.IdUsuario;

            return Task.FromResult(result);
        }

        private class RecoveryTokenInfo
        {
            public int IdUsuario { get; set; }
            public string Correo { get; set; } = string.Empty;
            public DateTime ExpirationDate { get; set; }
        }
    }
}
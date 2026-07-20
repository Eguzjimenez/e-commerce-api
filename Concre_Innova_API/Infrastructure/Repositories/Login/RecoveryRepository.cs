using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Infrastructure.Data;
using Concre_Innova_API.Domain.Entities;
using Microsoft.Data.SqlClient;
using System.Collections.Concurrent;
using System.Data;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;

namespace Concre_Innova_API.Infrastructure.Repositories.Login
{
    public class RecoveryRepository : IRecoveryRepository
    {
        private const int RecoveryCodeMinutesToLive = 10;
        private const int ResetTokenMinutesToLive = 15;
        private const int MaximumCodeValidationAttempts = 5;

        private readonly ISqlConnectionFactory _connectionFactory;

        private static readonly ConcurrentDictionary<string, RecoveryTokenInfo> RecoveryTokens = new();
        private static readonly ConcurrentDictionary<string, RecoveryCodeInfo> RecoveryCodesByEmail =
            new(StringComparer.OrdinalIgnoreCase);

        public RecoveryRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<UserLogin> ValidateEmailAsync(string correo)
        {
            var result = new UserLogin();

            await using var conn = _connectionFactory.CreateConnection();
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

        public Task<RecoveryCodeGenerationResponseDto> GenerateRecoveryTokenAsync(int idUsuario, string correo)
        {
            var normalizedEmail = NormalizeEmail(correo);
            var code = GenerateRecoveryCode();
            var expirationDate = DateTime.UtcNow.AddMinutes(RecoveryCodeMinutesToLive);

            RecoveryCodesByEmail[normalizedEmail] = new RecoveryCodeInfo
            {
                IdUsuario = idUsuario,
                Correo = normalizedEmail,
                CodeHash = HashRecoveryCode(normalizedEmail, code),
                ExpirationDate = expirationDate,
                RemainingAttempts = MaximumCodeValidationAttempts
            };

            var result = new RecoveryCodeGenerationResponseDto
            {
                Codigo = 1,
                Mensaje = "Codigo de recuperacion generado correctamente.",
                ExpiraEn = expirationDate,
                Correo = normalizedEmail,
                CodigoRecuperacion = code
            };

            return Task.FromResult(result);
        }

        public Task<RecoveryCodeVerificationResponseDto> ValidateRecoveryCodeAsync(
            string correo,
            string codigo)
        {
            var normalizedEmail = NormalizeEmail(correo);
            var normalizedCode = codigo.Trim();
            var result = new RecoveryCodeVerificationResponseDto();

            if (!RecoveryCodesByEmail.TryGetValue(normalizedEmail, out var codeInfo))
            {
                result.Codigo = 0;
                result.Mensaje = "No hay un codigo activo para este correo.";
                return Task.FromResult(result);
            }

            if (codeInfo.ExpirationDate < DateTime.UtcNow)
            {
                RecoveryCodesByEmail.TryRemove(normalizedEmail, out _);

                result.Codigo = 0;
                result.Mensaje = "El codigo de recuperacion ha expirado.";
                return Task.FromResult(result);
            }

            if (!string.Equals(
                    codeInfo.CodeHash,
                    HashRecoveryCode(normalizedEmail, normalizedCode),
                    StringComparison.Ordinal))
            {
                codeInfo.RemainingAttempts--;

                if (codeInfo.RemainingAttempts <= 0)
                    RecoveryCodesByEmail.TryRemove(normalizedEmail, out _);

                result.Codigo = 0;
                result.Mensaje = "El codigo de recuperacion no es valido.";
                return Task.FromResult(result);
            }

            RecoveryCodesByEmail.TryRemove(normalizedEmail, out _);

            var resetToken = Guid.NewGuid().ToString("N");
            RecoveryTokens[resetToken] = new RecoveryTokenInfo
            {
                IdUsuario = codeInfo.IdUsuario,
                Correo = codeInfo.Correo,
                ExpirationDate = DateTime.UtcNow.AddMinutes(ResetTokenMinutesToLive)
            };

            result.Codigo = 1;
            result.Mensaje = "Codigo verificado correctamente.";
            result.RecoveryToken = resetToken;

            return Task.FromResult(result);
        }

        public Task<UserLogin> ValidateRecoveryTokenAsync(string token)
        {
            return Task.FromResult(GetRecoveryTokenValidationResult(token, consumeToken: false));
        }

        public Task<UserLogin> ConsumeRecoveryTokenAsync(string token)
        {
            return Task.FromResult(GetRecoveryTokenValidationResult(token, consumeToken: true));
        }

        private static UserLogin GetRecoveryTokenValidationResult(string token, bool consumeToken)
        {
            var result = new UserLogin();

            if (string.IsNullOrWhiteSpace(token))
            {
                result.Codigo = 0;
                result.Mensaje = "El token de recuperacion es requerido.";
                return result;
            }

            if (!RecoveryTokens.TryGetValue(token, out var tokenInfo))
            {
                result.Codigo = 0;
                result.Mensaje = "El enlace de recuperacion no es valido.";
                return result;
            }

            if (tokenInfo.ExpirationDate < DateTime.UtcNow)
            {
                RecoveryTokens.TryRemove(token, out _);

                result.Codigo = 0;
                result.Mensaje = "El enlace de recuperacion ha expirado.";
                return result;
            }

            if (consumeToken)
                RecoveryTokens.TryRemove(token, out _);

            result.Codigo = 1;
            result.Mensaje = "El enlace de recuperacion es valido.";
            result.IdUsuario = tokenInfo.IdUsuario;

            return result;
        }

        private static string NormalizeEmail(string email)
        {
            return email.Trim().ToLowerInvariant();
        }

        private static string GenerateRecoveryCode()
        {
            return RandomNumberGenerator
                .GetInt32(100000, 1000000)
                .ToString(CultureInfo.InvariantCulture);
        }

        private static string HashRecoveryCode(string email, string code)
        {
            var bytes = SHA256.HashData(Encoding.UTF8.GetBytes($"{email}:{code}"));
            return Convert.ToHexString(bytes);
        }

        private class RecoveryCodeInfo
        {
            public int IdUsuario { get; set; }
            public string Correo { get; set; } = string.Empty;
            public string CodeHash { get; set; } = string.Empty;
            public DateTime ExpirationDate { get; set; }
            public int RemainingAttempts { get; set; }
        }

        private class RecoveryTokenInfo
        {
            public int IdUsuario { get; set; }
            public string Correo { get; set; } = string.Empty;
            public DateTime ExpirationDate { get; set; }
        }
    }
}

using Concre_Innova_API.Configuration.Settings;
using Concre_Innova_API.Shared.Constants;

namespace Concre_Innova_API.Configuration
{
    /// <summary>
    /// Verifica al arrancar que los secretos de seguridad esten configurados por entorno.
    /// Evita que la aplicacion funcione con la clave de ejemplo del andamiaje, que
    /// permitiria firmar tokens validos a cualquiera con acceso al repositorio.
    /// </summary>
    public static class SecurityConfigurationGuard
    {
        private const int LongitudMinimaClave = 32;

        private static readonly HashSet<string> ClavesNoPermitidas = new(StringComparer.OrdinalIgnoreCase)
        {
            "ReplaceWithAStrongSecretKey_AtLeast32Chars",
            "ChangeMe",
            "secret",
            "your-256-bit-secret"
        };

        public static JwtSettings ObtenerJwtSettingsValidados(this IConfiguration configuration)
        {
            var settings = configuration.GetSection(ConfigurationKeys.Jwt).Get<JwtSettings>() ?? new JwtSettings();
            var clave = settings.Key?.Trim() ?? string.Empty;

            if (string.IsNullOrEmpty(clave))
            {
                throw new InvalidOperationException(
                    "Falta la clave de firma de tokens. Configure 'Jwt:Key' con dotnet user-secrets " +
                    "o con la variable de entorno Jwt__Key antes de iniciar la aplicacion.");
            }

            if (clave.Length < LongitudMinimaClave)
            {
                throw new InvalidOperationException(
                    $"La clave de firma de tokens debe tener al menos {LongitudMinimaClave} caracteres.");
            }

            if (ClavesNoPermitidas.Contains(clave))
            {
                throw new InvalidOperationException(
                    "La clave de firma de tokens es un valor de ejemplo conocido. " +
                    "Genere una clave aleatoria propia para este entorno.");
            }

            return settings;
        }
    }
}

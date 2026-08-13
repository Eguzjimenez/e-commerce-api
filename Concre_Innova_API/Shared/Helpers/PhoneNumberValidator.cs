using System.Text.RegularExpressions;

namespace Concre_Innova_API.Shared.Helpers
{
    /// <summary>
    /// Valida numeros de telefono sin rechazar formatos legitimos: admite digitos,
    /// espacios, guiones, parentesis y prefijo internacional, y exige al menos
    /// ocho digitos reales para descartar textos sin sentido.
    /// </summary>
    public static class PhoneNumberValidator
    {
        private const int DigitosMinimos = 8;
        private const int DigitosMaximos = 15;

        private static readonly Regex CaracteresPermitidos =
            new(@"^\+?[0-9()\-\s\.]+$", RegexOptions.Compiled);

        public static bool IsValid(string? telefono)
        {
            if (string.IsNullOrWhiteSpace(telefono))
                return false;

            var valor = telefono.Trim();

            if (!CaracteresPermitidos.IsMatch(valor))
                return false;

            var digitos = valor.Count(char.IsDigit);
            return digitos >= DigitosMinimos && digitos <= DigitosMaximos;
        }

        /// <summary>
        /// Igual que <see cref="IsValid"/> pero acepta el valor vacio para los
        /// formularios donde el telefono es opcional.
        /// </summary>
        public static bool IsValidOrEmpty(string? telefono)
        {
            return string.IsNullOrWhiteSpace(telefono) || IsValid(telefono);
        }
    }
}

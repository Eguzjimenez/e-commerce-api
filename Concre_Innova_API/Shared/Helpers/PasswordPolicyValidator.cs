namespace Concre_Innova_API.Shared.Helpers
{
    public static class PasswordPolicyValidator
    {
        private const int MinimumLength = 8;

        public static string? GetValidationMessage(string? password)
        {
            if (string.IsNullOrWhiteSpace(password))
                return "La contraseña es requerida.";

            if (password.Length < MinimumLength)
                return "La contraseña debe tener al menos 8 caracteres.";

            if (!password.Any(char.IsUpper))
                return "La contraseña debe incluir al menos una letra mayuscula.";

            if (!password.Any(char.IsLower))
                return "La contraseña debe incluir al menos una letra minuscula.";

            if (!password.Any(char.IsDigit))
                return "La contraseña debe incluir al menos un número.";

            if (!password.Any(IsSpecialCharacter))
                return "La contraseña debe incluir al menos un caracter especial.";

            return null;
        }

        private static bool IsSpecialCharacter(char character)
        {
            return !char.IsLetterOrDigit(character);
        }
    }
}

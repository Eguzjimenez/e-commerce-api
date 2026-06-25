using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Requests.Login;
using Concre_Innova_API.Application.Interfaces.Validators;
using Concre_Innova_API.Shared.Helpers;

namespace Concre_Innova_API.Application.Validators
{
    public class AuthRequestValidator : IAuthRequestValidator
    {
        public string? ValidateLogin(UserLoginDto? request)
        {
            if (request == null ||
                string.IsNullOrWhiteSpace(request.Correo) ||
                string.IsNullOrWhiteSpace(request.Contrasena))
            {
                return "Correo y Contrasena son requeridos.";
            }

            return null;
        }

        public string? ValidateClientRegistration(RegisterClientRequest? request)
        {
            if (request == null)
                return "La informacion de registro es requerida.";

            if (string.IsNullOrWhiteSpace(request.Nombre) ||
                string.IsNullOrWhiteSpace(request.Correo) ||
                string.IsNullOrWhiteSpace(request.Telefono) ||
                string.IsNullOrWhiteSpace(request.Contrasena))
            {
                return "Nombre, correo, telefono y contrasena son requeridos.";
            }

            return EmailAddressValidator.IsValid(request.Correo)
                ? null
                : "El formato del correo no es valido.";
        }

        public string? ValidateEmail(EmailValidationRequest? request)
        {
            return request == null || string.IsNullOrEmpty(request.Correo)
                ? "Correo es requerido."
                : null;
        }

        public string? ValidateRecoveryEmail(EmailValidationRequest? request)
        {
            return request == null || string.IsNullOrWhiteSpace(request.Correo)
                ? "Correo es requerido."
                : null;
        }

        public string? ValidateRecoveryCode(RecoveryCodeVerificationRequest? request)
        {
            if (request == null ||
                string.IsNullOrWhiteSpace(request.Correo) ||
                string.IsNullOrWhiteSpace(request.Codigo))
            {
                return "Correo y codigo son requeridos.";
            }

            return request.Codigo.Trim().Length == 6 && request.Codigo.Trim().All(char.IsDigit)
                ? null
                : "El codigo debe tener 6 digitos.";
        }

        public string? ValidatePasswordReset(PasswordResetRequest? request)
        {
            return request == null ||
                string.IsNullOrWhiteSpace(request.RecoveryToken) ||
                string.IsNullOrEmpty(request.NuevaContrasena)
                ? "RecoveryToken y NuevaContrasena son requeridos."
                : null;
        }

        public string? ValidateRecoveryToken(string? token)
        {
            return string.IsNullOrWhiteSpace(token)
                ? "El token es requerido."
                : null;
        }
    }
}

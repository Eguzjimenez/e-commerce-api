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
                return "Correo y Contraseña son requeridos.";
            }

            return null;
        }

        public string? ValidateClientRegistration(RegisterClientRequest? request)
        {
            if (request == null)
                return "La información de registro es requerida.";

            if (string.IsNullOrWhiteSpace(request.Nombre) ||
                string.IsNullOrWhiteSpace(request.Apellido) ||
                string.IsNullOrWhiteSpace(request.Correo) ||
                string.IsNullOrWhiteSpace(request.Telefono) ||
                string.IsNullOrWhiteSpace(request.Direccion) ||
                string.IsNullOrWhiteSpace(request.Contrasena))
            {
                return "Nombre, apellido, correo, teléfono, dirección y contraseña son requeridos.";
            }

            if (request.Direccion.Trim().Length > 255)
            {
                return "La dirección no puede superar 255 caracteres.";
            }

            if (!EmailAddressValidator.IsValid(request.Correo))
                return "El formato del correo no es válido.";

            if (!PhoneNumberValidator.IsValid(request.Telefono))
                return "El teléfono debe contener entre 8 y 15 digitos.";

            return PasswordPolicyValidator.GetValidationMessage(request.Contrasena);
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
                return "Correo y código son requeridos.";
            }

            return request.Codigo.Trim().Length == 6 && request.Codigo.Trim().All(char.IsDigit)
                ? null
                : "El código debe tener 6 digitos.";
        }

        public string? ValidatePasswordReset(PasswordResetRequest? request)
        {
            if (request == null ||
                string.IsNullOrWhiteSpace(request.RecoveryToken) ||
                string.IsNullOrEmpty(request.NuevaContrasena))
            {
                return "RecoveryToken y NuevaContrasena son requeridos.";
            }

            return PasswordPolicyValidator.GetValidationMessage(request.NuevaContrasena);
        }

        public string? ValidateRecoveryToken(string? token)
        {
            return string.IsNullOrWhiteSpace(token)
                ? "El token es requerido."
                : null;
        }
    }
}

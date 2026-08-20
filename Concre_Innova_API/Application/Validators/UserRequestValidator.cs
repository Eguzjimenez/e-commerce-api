using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.Interfaces.Validators;
using Concre_Innova_API.Shared.Helpers;

namespace Concre_Innova_API.Application.Validators
{
    public class UserRequestValidator : IUserRequestValidator
    {
        public string? ValidateCreate(CreateUserRequest? request)
        {
            if (request == null)
                return "La información del usuario es requerida.";

            if (string.IsNullOrWhiteSpace(request.Nombre) ||
                string.IsNullOrWhiteSpace(request.Apellido) ||
                string.IsNullOrWhiteSpace(request.Correo) ||
                string.IsNullOrWhiteSpace(request.Contrasena) ||
                string.IsNullOrWhiteSpace(request.Telefono) ||
                request.IdRol <= 0)
            {
                return "Todos los campos son obligatorios.";
            }

            if (!EmailAddressValidator.IsValid(request.Correo))
                return "El formato del correo no es válido.";

            if (!PhoneNumberValidator.IsValid(request.Telefono))
                return "El teléfono debe contener entre 8 y 15 digitos.";

            return PasswordPolicyValidator.GetValidationMessage(request.Contrasena);
        }

        public string? ValidateUpdate(UpdateUserRequest? request)
        {
            if (request == null || request.IdUsuario <= 0)
                return "La información del usuario es requerida.";

            if (string.IsNullOrWhiteSpace(request.Nombre) ||
                string.IsNullOrWhiteSpace(request.Apellido) ||
                string.IsNullOrWhiteSpace(request.Correo) ||
                string.IsNullOrWhiteSpace(request.Telefono) ||
                request.IdRol <= 0)
            {
                return "Nombre, apellido, correo, teléfono e IdRol son requeridos.";
            }

            if (!EmailAddressValidator.IsValid(request.Correo))
                return "El formato del correo no es válido.";

            if (!PhoneNumberValidator.IsValid(request.Telefono))
                return "El teléfono debe contener entre 8 y 15 digitos.";

            return string.IsNullOrWhiteSpace(request.Contrasena)
                ? null
                : PasswordPolicyValidator.GetValidationMessage(request.Contrasena);
        }
    }
}

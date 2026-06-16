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
                return "La informacion del usuario es requerida.";

            if (string.IsNullOrWhiteSpace(request.Nombre) ||
                string.IsNullOrWhiteSpace(request.Apellido) ||
                string.IsNullOrWhiteSpace(request.Correo) ||
                string.IsNullOrWhiteSpace(request.Contrasena) ||
                string.IsNullOrWhiteSpace(request.Telefono) ||
                request.IdRol <= 0)
            {
                return "Todos los campos son obligatorios.";
            }

            return EmailAddressValidator.IsValid(request.Correo)
                ? null
                : "El formato del correo no es valido.";
        }

        public string? ValidateUpdate(UpdateUserRequest? request)
        {
            if (request == null || request.IdUsuario <= 0)
                return "La informacion del usuario es requerida.";

            if (string.IsNullOrWhiteSpace(request.Nombre) ||
                string.IsNullOrWhiteSpace(request.Apellido) ||
                string.IsNullOrWhiteSpace(request.Correo) ||
                string.IsNullOrWhiteSpace(request.Telefono) ||
                request.IdRol <= 0)
            {
                return "Nombre, apellido, correo, telefono e IdRol son requeridos.";
            }

            return EmailAddressValidator.IsValid(request.Correo)
                ? null
                : "El formato del correo no es valido.";
        }
    }
}

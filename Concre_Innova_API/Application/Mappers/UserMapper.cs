using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Domain.Entities;
using Concre_Innova_API.Domain.Constants;

namespace Concre_Innova_API.Application.Mappers
{
    public static class UserMapper
    {
        public static User ToClientUser(this RegisterClientRequest request)
        {
            var (nombre, apellido) = SplitFullName(request.Nombre ?? string.Empty);

            return new User
            {
                Nombre = nombre,
                Apellido = apellido,
                Correo = request.Correo?.Trim(),
                Telefono = request.Telefono?.Trim(),
                Contrasena = request.Contrasena,
                IdRol = AppRoles.Cliente
            };
        }

        public static User ToUser(this CreateUserRequest request)
        {
            return new User
            {
                Nombre = request.Nombre,
                Apellido = request.Apellido,
                Correo = request.Correo?.Trim(),
                Contrasena = request.Contrasena,
                Telefono = request.Telefono?.Trim(),
                IdRol = request.IdRol
            };
        }

        public static User ToUser(this UpdateUserRequest request)
        {
            return new User
            {
                IdUsuario = request.IdUsuario,
                Nombre = request.Nombre,
                Apellido = request.Apellido,
                Correo = request.Correo?.Trim(),
                Contrasena = request.Contrasena,
                Telefono = request.Telefono?.Trim(),
                IdRol = request.IdRol
            };
        }

        private static (string Nombre, string Apellido) SplitFullName(string fullName)
        {
            var parts = fullName
                .Trim()
                .Split(' ', 2, StringSplitOptions.RemoveEmptyEntries);

            var nombre =
                parts.Length > 0
                    ? parts[0]
                    : string.Empty;

            var apellido =
                parts.Length > 1
                    ? parts[1]
                    : "Cliente";

            return (nombre, apellido);
        }
    }
}

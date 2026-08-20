using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Domain.Entities;
using Concre_Innova_API.Domain.Constants;

namespace Concre_Innova_API.Application.Mappers
{
    public static class UserMapper
    {
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

    }
}

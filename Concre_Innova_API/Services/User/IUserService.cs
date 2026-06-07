using Concre_Innova_API.Models.Entities;
using Concre_Innova_API.Models.DTOs.Responses;

namespace Concre_Innova_API.Services
{
    public interface IUserService
    {
        Task<UserLogin> LoginAsync(string correo, string contrasena);
        Task<UserLogin> ValidateEmailAsync(string correo);
        Task<UserLogin> ResetPasswordAsync(int idUsuario, string nuevaContrasena);
        Task<IEnumerable<UserResponseDto>> GetUsersAsync();
        Task<Concre_Innova_API.Models.Entities.User> InsertUserAsync(Concre_Innova_API.Models.Entities.User user);
        Task<Concre_Innova_API.Models.Entities.User> UpdateUserAsync(Concre_Innova_API.Models.Entities.User user);
    }
}

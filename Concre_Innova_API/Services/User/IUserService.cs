using Concre_Innova_API.Models.Entities;
using Concre_Innova_API.Models.DTOs.Responses;

namespace Concre_Innova_API.Services
{
    public interface IUserService
    {
        Task<User> LoginAsync(string correo, string contrasena);
        Task<IEnumerable<UserResponseDto>> GetUsersAsync();
    }
}

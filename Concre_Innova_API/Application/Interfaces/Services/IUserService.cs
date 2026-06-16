using Concre_Innova_API.Domain.Entities;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface IUserService
    {
        Task<UserLogin> LoginAsync(string correo, string contrasena);

        Task<UserLogin> ValidateEmailAsync(string correo);

        Task<UserLogin> GenerateRecoveryTokenAsync(int idUsuario, string correo);

        Task<UserLogin> ValidateRecoveryTokenAsync(string token);

        Task<UserLogin> ResetPasswordAsync(int idUsuario, string nuevaContrasena);

        Task<IEnumerable<UserResponseDto>> GetUsersAsync();

        Task<UserDetailResponseDto?> GetUserByIdAsync(int idUsuario);

        Task<User> InsertUserAsync(User user);

        Task<User> UpdateUserAsync(User user);

        Task<User> DeactivateUserAsync(int idUsuario);
    }
}

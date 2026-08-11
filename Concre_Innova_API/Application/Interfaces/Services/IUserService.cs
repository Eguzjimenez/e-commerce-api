using Concre_Innova_API.Domain.Entities;
using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface IUserService
    {
        Task<UserLogin> LoginAsync(string correo, string contrasena);

        Task<UserLogin> ValidateEmailAsync(string correo);

        Task<RecoveryCodeGenerationResponseDto> GenerateRecoveryTokenAsync(int idUsuario, string correo);

        Task<RecoveryCodeVerificationResponseDto> ValidateRecoveryCodeAsync(string correo, string codigo);

        Task<UserLogin> ValidateRecoveryTokenAsync(string token);

        Task<UserLogin> ResetPasswordAsync(string recoveryToken, string nuevaContrasena);

        Task<UserLogin> ResetPasswordAsync(int idUsuario, string nuevaContrasena);

        Task<IEnumerable<UserResponseDto>> GetUsersAsync();

        Task<PaginatedResponseDto<UserResponseDto>> GetUsersPaginadosAsync(PaginationQuery pagination, string? busqueda, int? idRol);

        Task<UserDetailResponseDto?> GetUserByIdAsync(int idUsuario);

        Task<UserInfoResponseDto?> GetUserInfoAsync(int idUsuario);

        Task<User> InsertUserAsync(User user);

        Task<User> UpdateUserAsync(User user);

        Task<UpdateUserInfoResponseDto> UpdateUserInfoAsync(UpdateUserInfoRequest request);

        Task<User> DeactivateUserAsync(int idUsuario);
    }
}

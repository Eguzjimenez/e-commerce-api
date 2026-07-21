using Concre_Innova_API.Domain.Entities;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface IRecoveryRepository
    {
        Task<UserLogin> ValidateEmailAsync(string correo);

        Task<RecoveryCodeGenerationResponseDto> GenerateRecoveryTokenAsync(int idUsuario, string correo);

        Task<RecoveryCodeVerificationResponseDto> ValidateRecoveryCodeAsync(string correo, string codigo);

        Task<UserLogin> ValidateRecoveryTokenAsync(string token);

        Task<UserLogin> ConsumeRecoveryTokenAsync(string token);
    }
}

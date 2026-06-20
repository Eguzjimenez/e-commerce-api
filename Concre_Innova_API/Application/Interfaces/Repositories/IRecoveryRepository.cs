using Concre_Innova_API.Domain.Entities;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface IRecoveryRepository
    {
        Task<UserLogin> ValidateEmailAsync(string correo);

        Task<UserLogin> GenerateRecoveryTokenAsync(int idUsuario, string correo);

        Task<UserLogin> ValidateRecoveryTokenAsync(string token);
    }
}
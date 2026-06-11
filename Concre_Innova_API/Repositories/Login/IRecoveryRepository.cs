using Concre_Innova_API.Models.Entities;

namespace Concre_Innova_API.Repositories.Login
{
    public interface IRecoveryRepository
    {
        Task<UserLogin> ValidateEmailAsync(string correo);

        Task<UserLogin> GenerateRecoveryTokenAsync(int idUsuario, string correo);

        Task<UserLogin> ValidateRecoveryTokenAsync(string token);
    }
}
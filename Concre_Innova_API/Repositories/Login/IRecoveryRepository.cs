using Concre_Innova_API.Models.Entities;

namespace Concre_Innova_API.Repositories.Login
{
    public interface IRecoveryRepository
    {
        Task<UserLogin> ValidateEmailAsync(string correo);
    }
}

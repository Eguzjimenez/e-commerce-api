using Concre_Innova_API.Domain.Entities;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface IPasswordResetRepository
    {
        Task<UserLogin> ResetPasswordAsync(int idUsuario, string nuevaContrasena);
    }
}

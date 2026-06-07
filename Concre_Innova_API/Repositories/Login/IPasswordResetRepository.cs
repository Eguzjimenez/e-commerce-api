using Concre_Innova_API.Models.Entities;

namespace Concre_Innova_API.Repositories.Login
{
    public interface IPasswordResetRepository
    {
        Task<UserLogin> ResetPasswordAsync(int idUsuario, string nuevaContrasena);
    }
}

using Concre_Innova_API.Models.Entities;

namespace Concre_Innova_API.Repositories.Login
{
    public interface ILoginRepository
    {
        Task<UserLogin> LoginAsync(string correo, string contrasena);
    }
}

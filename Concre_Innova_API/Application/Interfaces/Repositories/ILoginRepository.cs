using Concre_Innova_API.Domain.Entities;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface ILoginRepository
    {
        Task<UserLogin> LoginAsync(string correo, string contrasena);
    }
}

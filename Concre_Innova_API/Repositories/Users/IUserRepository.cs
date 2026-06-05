using System.Collections.Generic;
using System.Threading.Tasks;
using Concre_Innova_API.Models.DTOs.Responses;
using Concre_Innova_API.Models.DTOs.Requests;
using Concre_Innova_API.Models.Entities;

namespace Concre_Innova_API.Repositories.Users
{
    public interface IUserRepository
    {
        Task<User> LoginAsync(string correo, string contrasena);
        Task<IEnumerable<UserResponseDto>> GetUsersAsync();
    }
}

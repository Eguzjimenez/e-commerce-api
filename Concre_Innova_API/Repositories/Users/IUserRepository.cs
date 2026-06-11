using System.Collections.Generic;
using System.Threading.Tasks;
using Concre_Innova_API.Models.DTOs.Responses;
using Concre_Innova_API.Models.DTOs.Requests;
using Concre_Innova_API.Models.Entities;

namespace Concre_Innova_API.Repositories.Users
{
    public interface IUserRepository
    {
        Task<IEnumerable<UserResponseDto>> GetUsersAsync();
        Task<UserDetailResponseDto?> GetUserByIdAsync(int idUsuario);
        Task<Concre_Innova_API.Models.Entities.User> InsertUserAsync(Concre_Innova_API.Models.Entities.User user);
        Task<Concre_Innova_API.Models.Entities.User> UpdateUserAsync(Concre_Innova_API.Models.Entities.User user);
        Task<Concre_Innova_API.Models.Entities.User> DeactivateUserAsync(int idUsuario);
    }
}

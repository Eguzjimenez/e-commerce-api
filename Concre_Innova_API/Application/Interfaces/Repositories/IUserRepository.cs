using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Domain.Entities;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface IUserRepository
    {
        Task<IEnumerable<UserResponseDto>> GetUsersAsync();
        Task<UserDetailResponseDto?> GetUserByIdAsync(int idUsuario);
        Task<User> InsertUserAsync(User user);
        Task<User> UpdateUserAsync(User user);
        Task<User> DeactivateUserAsync(int idUsuario);
    }
}

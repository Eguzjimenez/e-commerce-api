using Concre_Innova_API.Models.Entities;
using Concre_Innova_API.Models.DTOs.Responses;
using Concre_Innova_API.Repositories.Users;

namespace Concre_Innova_API.Services
{
    public class UserService : IUserService
    {
        private readonly IUserRepository _repo;

        public UserService(IUserRepository repo)
        {
            _repo = repo;
        }

        public Task<User> LoginAsync(string correo, string contrasena)
        {
            return _repo.LoginAsync(correo, contrasena);
        }

        public Task<IEnumerable<UserResponseDto>> GetUsersAsync()
        {
            return _repo.GetUsersAsync();
        }
    }
}

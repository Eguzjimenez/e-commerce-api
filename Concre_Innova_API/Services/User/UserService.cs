using Concre_Innova_API.Models.Entities;
using Concre_Innova_API.Models.DTOs.Responses;
using Concre_Innova_API.Repositories.Users;
using Concre_Innova_API.Repositories.Login;

namespace Concre_Innova_API.Services
{
    public class UserService : IUserService
    {
        private readonly IUserRepository _repo;
        private readonly ILoginRepository _loginRepo;
        private readonly IRecoveryRepository _recoveryRepo;
        private readonly IPasswordResetRepository _passwordResetRepo;

        public UserService(
            IUserRepository repo,
            ILoginRepository loginRepo,
            IRecoveryRepository recoveryRepo,
            IPasswordResetRepository passwordResetRepo)
        {
            _repo = repo;
            _loginRepo = loginRepo;
            _recoveryRepo = recoveryRepo;
            _passwordResetRepo = passwordResetRepo;
        }

        public Task<UserLogin> LoginAsync(string correo, string contrasena)
        {
            return _loginRepo.LoginAsync(correo, contrasena);
        }

        public Task<UserLogin> ValidateEmailAsync(string correo)
        {
            return _recoveryRepo.ValidateEmailAsync(correo);
        }

        // NUEVO
        public Task<UserLogin> GenerateRecoveryTokenAsync(int idUsuario, string correo)
        {
            return _recoveryRepo.GenerateRecoveryTokenAsync(idUsuario, correo);
        }

        // NUEVO
        public Task<UserLogin> ValidateRecoveryTokenAsync(string token)
        {
            return _recoveryRepo.ValidateRecoveryTokenAsync(token);
        }

        public Task<IEnumerable<UserResponseDto>> GetUsersAsync()
        {
            return _repo.GetUsersAsync();
        }

        public Task<UserDetailResponseDto?> GetUserByIdAsync(int idUsuario)
        {
            return _repo.GetUserByIdAsync(idUsuario);
        }

        public Task<UserLogin> ResetPasswordAsync(int idUsuario, string nuevaContrasena)
        {
            return _passwordResetRepo.ResetPasswordAsync(idUsuario, nuevaContrasena);
        }

        public Task<Models.Entities.User> InsertUserAsync(Models.Entities.User user)
        {
            return _repo.InsertUserAsync(user);
        }

        public Task<Models.Entities.User> UpdateUserAsync(Models.Entities.User user)
        {
            return _repo.UpdateUserAsync(user);
        }

        public Task<Models.Entities.User> DeactivateUserAsync(int idUsuario)
        {
            return _repo.DeactivateUserAsync(idUsuario);
        }
    }
}
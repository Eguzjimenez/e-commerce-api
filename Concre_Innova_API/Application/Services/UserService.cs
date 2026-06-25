using Concre_Innova_API.Domain.Entities;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;

namespace Concre_Innova_API.Application.Services
{
    public class UserService : IUserService
    {
        private readonly IUserRepository _userRepository;
        private readonly ILoginRepository _loginRepository;
        private readonly IRecoveryRepository _recoveryRepository;
        private readonly IPasswordResetRepository _passwordResetRepository;

        public UserService(
            IUserRepository repo,
            ILoginRepository loginRepo,
            IRecoveryRepository recoveryRepo,
            IPasswordResetRepository passwordResetRepo)
        {
            _userRepository = repo;
            _loginRepository = loginRepo;
            _recoveryRepository = recoveryRepo;
            _passwordResetRepository = passwordResetRepo;
        }

        public Task<UserLogin> LoginAsync(string correo, string contrasena)
        {
            return _loginRepository.LoginAsync(correo, contrasena);
        }

        public Task<UserLogin> ValidateEmailAsync(string correo)
        {
            return _recoveryRepository.ValidateEmailAsync(correo);
        }

        public Task<RecoveryCodeGenerationResponseDto> GenerateRecoveryTokenAsync(int idUsuario, string correo)
        {
            return _recoveryRepository.GenerateRecoveryTokenAsync(idUsuario, correo);
        }

        public Task<RecoveryCodeVerificationResponseDto> ValidateRecoveryCodeAsync(string correo, string codigo)
        {
            return _recoveryRepository.ValidateRecoveryCodeAsync(correo, codigo);
        }

        public Task<UserLogin> ValidateRecoveryTokenAsync(string token)
        {
            return _recoveryRepository.ValidateRecoveryTokenAsync(token);
        }

        public Task<IEnumerable<UserResponseDto>> GetUsersAsync()
        {
            return _userRepository.GetUsersAsync();
        }

        public Task<UserDetailResponseDto?> GetUserByIdAsync(int idUsuario)
        {
            return _userRepository.GetUserByIdAsync(idUsuario);
        }

        public Task<UserLogin> ResetPasswordAsync(int idUsuario, string nuevaContrasena)
        {
            return _passwordResetRepository.ResetPasswordAsync(idUsuario, nuevaContrasena);
        }

        public async Task<UserLogin> ResetPasswordAsync(string recoveryToken, string nuevaContrasena)
        {
            var tokenResult = await _recoveryRepository.ConsumeRecoveryTokenAsync(recoveryToken);

            if (tokenResult.Codigo != 1 || !tokenResult.IdUsuario.HasValue)
            {
                return tokenResult;
            }

            var resetResult = await _passwordResetRepository.ResetPasswordAsync(
                tokenResult.IdUsuario.Value,
                nuevaContrasena);

            if (resetResult.Codigo == 1)
            {
                resetResult.IdUsuario = tokenResult.IdUsuario;
            }

            return resetResult;
        }

        public Task<User> InsertUserAsync(User user)
        {
            return _userRepository.InsertUserAsync(user);
        }

        public Task<User> UpdateUserAsync(User user)
        {
            return _userRepository.UpdateUserAsync(user);
        }

        public Task<User> DeactivateUserAsync(int idUsuario)
        {
            return _userRepository.DeactivateUserAsync(idUsuario);
        }
    }
}

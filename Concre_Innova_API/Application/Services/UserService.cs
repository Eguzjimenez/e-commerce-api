using Concre_Innova_API.Domain.Entities;
using Concre_Innova_API.Domain.Constants;
using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;
using System.Security.Claims;

namespace Concre_Innova_API.Application.Services
{
    public class UserService : IUserService
    {
        private readonly IUserRepository _userRepository;
        private readonly ILoginRepository _loginRepository;
        private readonly IRecoveryRepository _recoveryRepository;
        private readonly IPasswordResetRepository _passwordResetRepository;
        private readonly ITokenService _tokenService;

        public UserService(
            IUserRepository repo,
            ILoginRepository loginRepo,
            IRecoveryRepository recoveryRepo,
            IPasswordResetRepository passwordResetRepo,
            ITokenService tokenService)
        {
            _userRepository = repo;
            _loginRepository = loginRepo;
            _recoveryRepository = recoveryRepo;
            _passwordResetRepository = passwordResetRepo;
            _tokenService = tokenService;
        }

        public async Task<UserLogin> LoginAsync(string correo, string contrasena)
        {
            var result = await _loginRepository.LoginAsync(correo, contrasena);

            if (result.Codigo == 1 &&
                result.IdUsuario.HasValue &&
                result.IdRol.HasValue)
            {
                result.NombreRol = AppRoles.GetName(result.IdRol);
                result.Token = _tokenService.GenerateToken(CreateLoginClaims(result));
            }

            return result;
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

        public Task<PaginatedResponseDto<UserResponseDto>> GetUsersPaginadosAsync(
            PaginationQuery pagination,
            string? busqueda,
            int? idRol)
        {
            return _userRepository.GetUsersPaginadosAsync(pagination, busqueda, idRol);
        }

        public Task<UserDetailResponseDto?> GetUserByIdAsync(int idUsuario)
        {
            return _userRepository.GetUserByIdAsync(idUsuario);
        }

        public Task<UserInfoResponseDto?> GetUserInfoAsync(int idUsuario)
        {
            return _userRepository.GetUserInfoAsync(idUsuario);
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

        public Task<UpdateUserInfoResponseDto> UpdateUserInfoAsync(UpdateUserInfoRequest request)
        {
            return _userRepository.UpdateUserInfoAsync(request);
        }

        public Task<User> DeactivateUserAsync(int idUsuario)
        {
            return _userRepository.DeactivateUserAsync(idUsuario);
        }

        private static IEnumerable<Claim> CreateLoginClaims(UserLogin user)
        {
            var roleName = AppRoles.GetName(user.IdRol);

            return new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.IdUsuario!.Value.ToString()),
                new Claim(ClaimTypes.Role, roleName),
                new Claim("idRol", user.IdRol!.Value.ToString()),
                new Claim("nombreRol", roleName)
            };
        }
    }
}

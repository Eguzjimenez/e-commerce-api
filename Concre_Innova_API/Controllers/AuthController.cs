using Microsoft.AspNetCore.Mvc;
using Concre_Innova_API.Application.Mappers;
using Concre_Innova_API.Domain.Entities;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Interfaces.Validators;
using Concre_Innova_API.Application.DTOs.Requests.Login;
using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Configuration.Settings;
using Concre_Innova_API.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly IEmailService _emailService;
        private readonly IAuthRequestValidator _validator;
        private readonly ILoginAttemptService _loginAttemptService;
        private readonly IAuditService _auditService;
        private readonly ITokenService _tokenService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly JwtSettings _jwtSettings;

        public AuthController(
            IUserService userService,
            IEmailService emailService,
            IAuthRequestValidator validator,
            ILoginAttemptService loginAttemptService,
            IAuditService auditService,
            ITokenService tokenService,
            IRequestUserContextService requestUserContextService,
            JwtSettings jwtSettings)
        {
            _userService = userService;
            _emailService = emailService;
            _validator = validator;
            _loginAttemptService = loginAttemptService;
            _auditService = auditService;
            _tokenService = tokenService;
            _requestUserContextService = requestUserContextService;
            _jwtSettings = jwtSettings;
        }

        [HttpPost("login")]
        public async Task<ActionResult<UserLogin>> Login([FromBody] UserLoginDto request)
        {
            var validationMessage = _validator.ValidateLogin(request);
            if (validationMessage != null)
                return BadRequest(new { message = validationMessage });

            var correo = request!.Correo!.Trim();
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? string.Empty;

            if (_loginAttemptService.IsBlocked(correo, out var blockedUntil))
            {
                await _auditService.RecordLoginAttemptAsync(
                    null,
                    correo,
                    wasSuccessful: false,
                    ipAddress,
                    "Intento de inicio de sesion bloqueado por multiples fallos.");

                return StatusCode(StatusCodes.Status429TooManyRequests, new
                {
                    message = $"Cuenta temporalmente bloqueada. Intente nuevamente despues de {blockedUntil:O}."
                });
            }

            UserLogin result = await _userService.LoginAsync(request!.Correo!, request.Contrasena!);

            if (result.Codigo != 1)
            {
                _loginAttemptService.RecordFailedAttempt(correo);

                await _auditService.RecordLoginAttemptAsync(
                    result.IdUsuario,
                    correo,
                    wasSuccessful: false,
                    ipAddress,
                    result.Mensaje ?? "Inicio de sesion fallido.");

                return Unauthorized(result);
            }

            _loginAttemptService.ResetAttempts(correo);

            await _auditService.RecordLoginAttemptAsync(
                result.IdUsuario,
                correo,
                wasSuccessful: true,
                ipAddress,
                result.Mensaje ?? "Inicio de sesion exitoso.");

            return Ok(result);
        }

        [HttpPost("register-client")]
        public async Task<ActionResult<User>> RegisterClient([FromBody] RegisterClientRequest request)
        {
            var validationMessage = _validator.ValidateClientRegistration(request);
            if (validationMessage != null)
                return BadRequest(new { message = validationMessage });

            // El alta crea la cuenta y su ficha de cliente con la direccion incluida.
            var result = await _userService.RegistrarClienteAsync(request!);

            if (result == null)
                return StatusCode(500, "Error creating client");

            if (result.Codigo != 1)
                return BadRequest(result.Mensaje);

            await _emailService.SendWelcomeEmailAsync(
                request.Correo!.Trim(),
                request.Nombre!.Trim());

            return CreatedAtAction(
                nameof(Login),
                new { id = result.IdUsuario },
                result);
        }

        [HttpPost("validate-email")]
        public async Task<IActionResult> ValidateEmail([FromBody] EmailValidationRequest request)
        {
            var validationMessage = _validator.ValidateEmail(request);
            if (validationMessage != null)
                return BadRequest(new { message = validationMessage });

            var result = await _userService.ValidateEmailAsync(request!.Correo!);

            return Ok(result);
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] PasswordResetRequest request)
        {
            var validationMessage = _validator.ValidatePasswordReset(request);
            if (validationMessage != null)
                return BadRequest(new { message = validationMessage });

            var result = await _userService.ResetPasswordAsync(
                request!.RecoveryToken!,
                request.NuevaContrasena!);

            if (result.Codigo == 1)
            {
                var user = result.IdUsuario.HasValue
                    ? await _userService.GetUserByIdAsync(result.IdUsuario.Value)
                    : null;

                if (!string.IsNullOrWhiteSpace(user?.Correo))
                    await _emailService.SendPasswordResetNotificationAsync(user.Correo, DateTime.UtcNow);
            }

            return Ok(result);
        }

        [HttpPost("generate-recovery-token")]
        public async Task<IActionResult> GenerateRecoveryToken([FromBody] EmailValidationRequest request)
        {
            var validationMessage = _validator.ValidateRecoveryEmail(request);
            if (validationMessage != null)
                return BadRequest(new { message = validationMessage });

            var validationResult = await _userService.ValidateEmailAsync(request!.Correo!);

            if (validationResult.Codigo != 1)
                return BadRequest(validationResult);

            if (!validationResult.IdUsuario.HasValue)
                return BadRequest(new { message = "No se pudo identificar el usuario." });

            var tokenResult = await _userService.GenerateRecoveryTokenAsync(
                validationResult.IdUsuario.Value,
                request.Correo!);

            if (tokenResult.Codigo == 1 &&
                !string.IsNullOrWhiteSpace(tokenResult.Correo) &&
                !string.IsNullOrWhiteSpace(tokenResult.CodigoRecuperacion) &&
                tokenResult.ExpiraEn.HasValue)
            {
                await _emailService.SendPasswordRecoveryCodeAsync(
                    tokenResult.Correo,
                    tokenResult.CodigoRecuperacion,
                    tokenResult.ExpiraEn.Value);
            }

            return Ok(tokenResult);
        }

        [HttpPost("verify-recovery-code")]
        public async Task<IActionResult> VerifyRecoveryCode([FromBody] RecoveryCodeVerificationRequest request)
        {
            var validationMessage = _validator.ValidateRecoveryCode(request);
            if (validationMessage != null)
                return BadRequest(new { message = validationMessage });

            var result = await _userService.ValidateRecoveryCodeAsync(
                request!.Correo!,
                request.Codigo!);

            if (result.Codigo != 1)
                return BadRequest(result);

            return Ok(result);
        }

        [HttpPost("validate-recovery-token")]
        public async Task<IActionResult> ValidateRecoveryToken([FromBody] string token)
        {
            var validationMessage = _validator.ValidateRecoveryToken(token);
            if (validationMessage != null)
                return BadRequest(new { message = validationMessage });

            var result = await _userService.ValidateRecoveryTokenAsync(token);

            if (result.Codigo != 1)
                return BadRequest(result);

            return Ok(result);
        }
        /// <summary>
        /// Renueva el token de una sesion que sigue activa. El cliente lo llama
        /// mientras la persona trabaja, para que no se le expulse a mitad de una
        /// tarea solo porque el token original ya cumplio su vigencia.
        /// </summary>
        [Authorize]
        [HttpPost("refresh")]
        public ActionResult<SesionRenovadaResponseDto> RefrescarSesion()
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue || !userContext.RoleId.HasValue)
                return Unauthorized(new { message = "La sesion no esta activa." });

            var nombreRol = AppRoles.GetName(userContext.RoleId.Value);

            var token = _tokenService.GenerateToken(new[]
            {
                new Claim(ClaimTypes.NameIdentifier, userContext.UserId.Value.ToString()),
                new Claim(ClaimTypes.Role, nombreRol),
                new Claim("idRol", userContext.RoleId.Value.ToString()),
                new Claim("nombreRol", nombreRol)
            });

            return Ok(new SesionRenovadaResponseDto
            {
                Token = token,
                MinutosVigencia = _jwtSettings.ExpireMinutes
            });
        }

    }
}

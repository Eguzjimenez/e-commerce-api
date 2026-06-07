using Microsoft.AspNetCore.Mvc;
using Concre_Innova_API.Models.Entities;
using Concre_Innova_API.Services;
using Concre_Innova_API.Models.DTOs.Requests.Login;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IUserService _userService;

        public AuthController(IUserService userService)
        {
            _userService = userService;
        }

        [HttpPost("login")]
        public async Task<ActionResult<UserLogin>> Login([FromBody] UserLoginDto request)
        {
            if (request == null || string.IsNullOrEmpty(request.Correo) || string.IsNullOrEmpty(request.Contrasena))
                return BadRequest(new { message = "Correo y Contrasena son requeridos." });
            UserLogin result = await _userService.LoginAsync(request.Correo, request.Contrasena);
            return Ok(result);
        }
        [HttpPost("validate-email")]
        public async Task<IActionResult> ValidateEmail([FromBody] EmailValidationRequest request)
        {
            if (request == null || string.IsNullOrEmpty(request.Correo))
                return BadRequest(new { message = "Correo es requerido." });

            var result = await _userService.ValidateEmailAsync(request.Correo);
            return Ok(result);
        }
        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] PasswordResetRequest request)
        {
            if (request == null || request.IdUsuario <= 0 || string.IsNullOrEmpty(request.NuevaContrasena))
                return BadRequest(new { message = "IdUsuario y NuevaContrasena son requeridos." });

            var result = await _userService.ResetPasswordAsync(request.IdUsuario, request.NuevaContrasena);
            return Ok(result);
        }
    }
}

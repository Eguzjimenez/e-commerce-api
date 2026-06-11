using Microsoft.AspNetCore.Mvc;
using Concre_Innova_API.Models.Entities;
using Concre_Innova_API.Services;
using Concre_Innova_API.Models.DTOs.Requests.Login;
using Concre_Innova_API.Models.DTOs.Requests;
using Concre_Innova_API.Security;
using Concre_Innova_API.Services.Email;
using System.Net.Mail;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly IEmailService _emailService;

        public AuthController(IUserService userService, IEmailService emailService)
        {
            _userService = userService;
            _emailService = emailService;
        }

        [HttpPost("login")]
        public async Task<ActionResult<UserLogin>> Login([FromBody] UserLoginDto request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.Correo) || string.IsNullOrWhiteSpace(request.Contrasena))
                return BadRequest(new { message = "Correo y Contrasena son requeridos." });

            UserLogin result = await _userService.LoginAsync(request.Correo, request.Contrasena);
            if (result.Codigo != 1)
                return Unauthorized(result);

            return Ok(result);
        }

        [HttpPost("register-client")]
        public async Task<ActionResult<User>> RegisterClient([FromBody] RegisterClientRequest request)
        {
            if (request == null)
                return BadRequest(new { message = "La informacion de registro es requerida." });

            if (string.IsNullOrWhiteSpace(request.Nombre) ||
                string.IsNullOrWhiteSpace(request.Correo) ||
                string.IsNullOrWhiteSpace(request.Telefono) ||
                string.IsNullOrWhiteSpace(request.Contrasena))
            {
                return BadRequest(new { message = "Nombre, correo, telefono y contrasena son requeridos." });
            }

            if (!IsValidEmail(request.Correo))
                return BadRequest(new { message = "El formato del correo no es valido." });

            var (nombre, apellido) = SplitFullName(request.Nombre);
            var user = new User
            {
                Nombre = nombre,
                Apellido = apellido,
                Correo = request.Correo.Trim(),
                Telefono = request.Telefono.Trim(),
                Contrasena = request.Contrasena,
                IdRol = AppRoles.Cliente
            };

            var result = await _userService.InsertUserAsync(user);
            if (result == null)
                return StatusCode(500, "Error creating client");

            if (result.Codigo != 1)
                return BadRequest(result.Mensaje);

            await _emailService.SendWelcomeEmailAsync(request.Correo.Trim(), request.Nombre.Trim());

            return CreatedAtAction(nameof(Login), new { id = result.IdUsuario }, result);
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

        private static bool IsValidEmail(string email)
        {
            try
            {
                var address = new MailAddress(email);
                return address.Address == email.Trim();
            }
            catch
            {
                return false;
            }
        }

        private static (string Nombre, string Apellido) SplitFullName(string fullName)
        {
            var parts = fullName.Trim().Split(' ', 2, StringSplitOptions.RemoveEmptyEntries);
            var nombre = parts.Length > 0 ? parts[0] : string.Empty;
            var apellido = parts.Length > 1 ? parts[1] : "Cliente";

            return (nombre, apellido);
        }
    }
}

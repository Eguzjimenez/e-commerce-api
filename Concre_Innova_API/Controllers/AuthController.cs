using Microsoft.AspNetCore.Mvc;
using Concre_Innova_API.Models.DTOs.Requests;
using Concre_Innova_API.Models.Entities;
using Concre_Innova_API.Services;

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
        public async Task<IActionResult> Login([FromBody] UserLoginDto request)
        {
            if (request == null || string.IsNullOrEmpty(request.Correo) || string.IsNullOrEmpty(request.Contrasena))
                return BadRequest(new { message = "Correo y Contrasena son requeridos." });

            var result = await _userService.LoginAsync(request.Correo, request.Contrasena);
            return Ok(result);
        }
    }
}

using Microsoft.AspNetCore.Mvc;
using Concre_Innova_API.Models.DTOs.Responses;
using Concre_Innova_API.Services;
using Concre_Innova_API.Models.DTOs.Requests;
using Concre_Innova_API.Models.Entities;
using Concre_Innova_API.Security;
using Concre_Innova_API.Services.Audit;
using Concre_Innova_API.Services.Security;
using System.Net.Mail;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;

        public UsersController(
            IUserService userService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService)
        {
            _userService = userService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
        }

        [HttpGet("UserList")]
        public async Task<ActionResult<IEnumerable<UserResponseDto>>> UserList()
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequireAdminAsync(userContext, "Usuarios", "ACCESS");
            if (denied != null)
                return denied;

            await _auditService.RecordAsync(
                userContext,
                "Usuarios",
                "ACCESS",
                "Acceso al modulo de gestion de usuarios.");

            var users = await _userService.GetUsersAsync();
            return Ok(users);
        }

        [HttpGet("{idUsuario:int}")]
        public async Task<ActionResult<UserDetailResponseDto>> GetUserDetail(int idUsuario)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequireAdminAsync(userContext, "Usuarios", "ACCESS");
            if (denied != null)
                return denied;

            var user = await _userService.GetUserByIdAsync(idUsuario);
            if (user == null)
                return NotFound(new { message = "El usuario no existe." });

            await _auditService.RecordAsync(
                userContext,
                "Usuarios",
                "ACCESS",
                $"Consulta del detalle del usuario {idUsuario}.");

            return Ok(user);
        }

        [HttpPost("NewUser")]
        public async Task<ActionResult<User>> NewUser([FromBody] CreateUserRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequireAdminAsync(userContext, "Usuarios", "CREATE");
            if (denied != null)
                return denied;

            if (request == null)
                return BadRequest(new { message = "La informacion del usuario es requerida." });

            if (string.IsNullOrWhiteSpace(request.Nombre) ||
                string.IsNullOrWhiteSpace(request.Apellido) ||
                string.IsNullOrWhiteSpace(request.Correo) ||
                string.IsNullOrWhiteSpace(request.Contrasena) ||
                string.IsNullOrWhiteSpace(request.Telefono) ||
                request.IdRol <= 0)
            {
                return BadRequest(new { message = "Todos los campos son obligatorios." });
            }

            if (!IsValidEmail(request.Correo))
            {
                return BadRequest(new { message = "El formato del correo no es valido." });
            }

            var user = new User
            {
                Nombre = request.Nombre,
                Apellido = request.Apellido,
                Correo = request.Correo.Trim(),
                Contrasena = request.Contrasena,
                Telefono = request.Telefono.Trim(),
                IdRol = request.IdRol
            };

            var result = await _userService.InsertUserAsync(user);

            if (result == null)
                return StatusCode(500, "Error creating user");

            if (result.Codigo == 1)
            {
                await _auditService.RecordAsync(
                    userContext,
                    "Usuarios",
                    "CREATE",
                    $"Creacion del usuario {result.IdUsuario} con rol {request.IdRol}.");

                return CreatedAtAction(nameof(GetUserDetail), new { idUsuario = result.IdUsuario }, result);
            }

            return BadRequest(result.Mensaje);
        }

        [HttpPut("UpdateUser")]
        public async Task<ActionResult> UpdateUser([FromBody] UpdateUserRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequireAdminAsync(userContext, "Usuarios", "UPDATE");
            if (denied != null)
                return denied;

            if (request == null || request.IdUsuario <= 0)
                return BadRequest(new { message = "La informacion del usuario es requerida." });

            if (string.IsNullOrWhiteSpace(request.Nombre) ||
                string.IsNullOrWhiteSpace(request.Apellido) ||
                string.IsNullOrWhiteSpace(request.Correo) ||
                string.IsNullOrWhiteSpace(request.Telefono) ||
                request.IdRol <= 0)
            {
                return BadRequest(new { message = "Nombre, apellido, correo, telefono e IdRol son requeridos." });
            }

            if (!IsValidEmail(request.Correo))
            {
                return BadRequest(new { message = "El formato del correo no es valido." });
            }

            var user = new User
            {
                IdUsuario = request.IdUsuario,
                Nombre = request.Nombre,
                Apellido = request.Apellido,
                Correo = request.Correo.Trim(),
                Contrasena = request.Contrasena,
                Telefono = request.Telefono.Trim(),
                IdRol = request.IdRol
            };

            var result = await _userService.UpdateUserAsync(user);

            if (result == null)
                return StatusCode(500, "Error updating user");

            if (result.Codigo == 1)
            {
                await _auditService.RecordAsync(
                    userContext,
                    "Usuarios",
                    "UPDATE",
                    $"Actualizacion del usuario {request.IdUsuario}.");

                return Ok(result.Mensaje);
            }

            return BadRequest(result.Mensaje);
        }

        [HttpDelete("{idUsuario:int}")]
        public async Task<ActionResult> DeactivateUser(int idUsuario)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequireAdminAsync(userContext, "Usuarios", "DELETE");
            if (denied != null)
                return denied;

            var result = await _userService.DeactivateUserAsync(idUsuario);

            if (result == null)
                return StatusCode(500, "Error deactivating user");

            if (result.Codigo == 1)
            {
                await _auditService.RecordAsync(
                    userContext,
                    "Usuarios",
                    "DELETE",
                    $"Desactivacion logica del usuario {idUsuario}.");

                return Ok(result.Mensaje);
            }

            return BadRequest(result.Mensaje);
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

        private async Task<ActionResult?> RequireAdminAsync(
            RequestUserContext userContext,
            string module,
            string operation)
        {
            if (!userContext.IsAuthenticated)
                return Unauthorized(new { message = "Debe iniciar sesion para acceder a este recurso." });

            if (userContext.RoleId != AppRoles.Administrador)
            {
                await _auditService.RecordAsync(
                    userContext,
                    module,
                    "DENIED",
                    $"Intento no autorizado de {operation}.");

                return StatusCode(
                    StatusCodes.Status403Forbidden,
                    new { message = "No tiene permisos para realizar esta accion." });
            }

            return null;
        }
    }
}
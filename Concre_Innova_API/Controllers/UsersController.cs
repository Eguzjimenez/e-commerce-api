using Microsoft.AspNetCore.Mvc;
using Concre_Innova_API.Application.Mappers;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Interfaces.Validators;
using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.Security;
using Concre_Innova_API.Domain.Entities;
using Concre_Innova_API.Domain.Constants;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;
        private readonly IUserRequestValidator _validator;

        public UsersController(
            IUserService userService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService,
            IUserRequestValidator validator)
        {
            _userService = userService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
            _validator = validator;
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

            var validationMessage = _validator.ValidateCreate(request);
            if (validationMessage != null)
                return BadRequest(new { message = validationMessage });

            var user = request.ToUser();
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

            var validationMessage = _validator.ValidateUpdate(request);
            if (validationMessage != null)
                return BadRequest(new { message = validationMessage });

            var user = request.ToUser();
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

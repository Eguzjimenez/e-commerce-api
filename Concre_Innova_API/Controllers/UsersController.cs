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
        private readonly IPermissionService _permissionService;

        public UsersController(
            IUserService userService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService,
            IUserRequestValidator validator,
            IPermissionService permissionService)
        {
            _userService = userService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
            _validator = validator;
            _permissionService = permissionService;
        }

        [HttpGet("UserList")]
        public async Task<ActionResult> UserList(
            [FromQuery] int? pagina = null,
            [FromQuery] int? tamanoPagina = null,
            [FromQuery] string? busqueda = null,
            [FromQuery] int? idRol = null)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.UsuariosVer, "ACCESS");
            if (denied != null)
                return denied;

            await _auditService.RecordAsync(
                userContext,
                "Usuarios",
                "ACCESS",
                "Acceso al modulo de gestión de usuarios.");

            var pagination = new PaginationQuery(pagina, tamanoPagina, defaultPageSize: 25);
            if (pagination.IsRequested)
            {
                var pagedUsers = await _userService.GetUsersPaginadosAsync(
                    pagination,
                    busqueda,
                    idRol);
                return Ok(pagedUsers);
            }

            var users = await _userService.GetUsersAsync();
            return Ok(users);
        }

        [HttpGet("{idUsuario:int}")]
        public async Task<ActionResult<UserDetailResponseDto>> GetUserDetail(int idUsuario)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.UsuariosVer, "ACCESS");
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

        [HttpGet("info/{idUsuario:int}")]
        public async Task<ActionResult<UserInfoResponseDto>> GetUserInfo(int idUsuario)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            // Si no está autenticado, negar acceso
            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
                return Unauthorized(new { message = "Debe iniciar sesión para acceder a este recurso." });

            // Permitir que el usuario vea su propia información
            // O que un admin vea cualquier información
            bool isOwnProfile = userContext.UserId.Value == idUsuario;
            bool isAdmin = userContext.RoleId.HasValue && 
                           await _permissionService.RoleHasPermissionAsync(userContext.RoleId.Value, PermissionCodes.UsuariosVer);

            if (!isOwnProfile && !isAdmin)
            {
                await _auditService.RecordAsync(
                    userContext,
                    "Usuarios",
                    "DENIED",
                    $"Intento no autorizado de acceder a la información del usuario {idUsuario}.");

                return StatusCode(
                    StatusCodes.Status403Forbidden,
                    new { message = "No tiene permisos para ver la información de otro usuario." });
            }

            var userInfo = await _userService.GetUserInfoAsync(idUsuario);
            if (userInfo == null)
                return NotFound(new { message = "El usuario no existe." });

            await _auditService.RecordAsync(
                userContext,
                "Usuarios",
                "ACCESS",
                $"Consulta de información completa del usuario {idUsuario}.");

            return Ok(userInfo);
        }

        [HttpGet("info/me")]
        public async Task<ActionResult<UserInfoResponseDto>> GetMyInfo()
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
                return Unauthorized(new { message = "Debe iniciar sesión para acceder a este recurso." });

            var userInfo = await _userService.GetUserInfoAsync(userContext.UserId.Value);
            if (userInfo == null)
                return NotFound(new { message = "El usuario no existe." });

            await _auditService.RecordAsync(
                userContext,
                "Usuarios",
                "ACCESS",
                "Consulta de información propia del usuario.");

            return Ok(userInfo);
        }

        [HttpPost("NewUser")]
        public async Task<ActionResult<User>> NewUser([FromBody] CreateUserRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.UsuariosCrear, "CREATE");
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
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.UsuariosActualizar, "UPDATE");
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
                    $"Actualización del usuario {request.IdUsuario}.");

                return Ok(result.Mensaje);
            }

            return BadRequest(result.Mensaje);
        }

        [HttpPut("UpdateUserInfo")]
        public async Task<ActionResult<UpdateUserInfoResponseDto>> UpdateUserInfo([FromBody] UpdateUserInfoRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            // Si no está autenticado, negar acceso
            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
                return Unauthorized(new { message = "Debe iniciar sesión para acceder a este recurso." });

            if (request == null || request.IdUsuario <= 0)
                return BadRequest(new { message = "Datos de solicitud inválidos." });

            // Permitir que el usuario actualice su propia información
            // O que un admin actualice cualquier información
            bool isOwnProfile = userContext.UserId.Value == request.IdUsuario;
            bool isAdmin = userContext.RoleId.HasValue && 
                           await _permissionService.RoleHasPermissionAsync(userContext.RoleId.Value, PermissionCodes.UsuariosActualizar);

            if (!isOwnProfile && !isAdmin)
            {
                await _auditService.RecordAsync(
                    userContext,
                    "Usuarios",
                    "DENIED",
                    $"Intento no autorizado de actualizar la información del usuario {request.IdUsuario}.");

                return StatusCode(
                    StatusCodes.Status403Forbidden,
                    new { message = "No tiene permisos para actualizar la información de otro usuario." });
            }

            var result = await _userService.UpdateUserInfoAsync(request);

            if (result == null)
                return StatusCode(500, new { message = "Error al actualizar la información del usuario." });

            if (result.Codigo == 1)
            {
                await _auditService.RecordAsync(
                    userContext,
                    "Usuarios",
                    "UPDATE",
                    $"Actualización completa de información del usuario {request.IdUsuario}.");

                return Ok(result);
            }

            return BadRequest(new { message = result.Mensaje });
        }

        [HttpDelete("{idUsuario:int}")]
        public async Task<ActionResult> DeactivateUser(int idUsuario)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.UsuariosEliminar, "DELETE");
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

        private async Task<ActionResult?> RequirePermissionAsync(
            RequestUserContext userContext,
            string permissionCode,
            string operation)
        {
            if (!userContext.IsAuthenticated || !userContext.RoleId.HasValue)
                return Unauthorized(new { message = "Debe iniciar sesión para acceder a este recurso." });

            var hasPermission = await _permissionService.RoleHasPermissionAsync(
                userContext.RoleId.Value,
                permissionCode);

            if (hasPermission)
                return null;

            await _auditService.RecordAsync(
                userContext,
                "Usuarios",
                "DENIED",
                $"Intento no autorizado de {operation} con permiso {permissionCode}.");

            return StatusCode(
                StatusCodes.Status403Forbidden,
                new { message = "No tiene permisos para realizar esta acción." });
        }
    }
}

using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Security;
using Concre_Innova_API.Domain.Constants;
using Microsoft.AspNetCore.Mvc;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PermisosController : ControllerBase
    {
        private readonly IPermissionService _permissionService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;

        public PermisosController(
            IPermissionService permissionService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService)
        {
            _permissionService = permissionService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
        }

        [HttpGet("roles")]
        public async Task<ActionResult<IEnumerable<RolePermissionsResponseDto>>> GetRolePermissions()
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.PermisosGestionar, "READ");
            if (denied != null)
                return denied;

            await _auditService.RecordAsync(
                userContext,
                "Permisos",
                "ACCESS",
                "Consulta de permisos por rol.");

            var permissions = await _permissionService.GetRolePermissionsAsync();
            return Ok(permissions);
        }

        [HttpPut("roles/{idRol:int}")]
        public async Task<ActionResult<OperacionResponseDto>> UpdateRolePermissions(
            int idRol,
            [FromBody] UpdateRolePermissionsRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.PermisosGestionar, "UPDATE");
            if (denied != null)
                return denied;

            if (request == null || request.IdRol != idRol)
                return BadRequest(new { message = "El rol de la URL no coincide con el cuerpo de la solicitud." });

            var result = await _permissionService.UpdateRolePermissionsAsync(request);

            await _auditService.RecordAsync(
                userContext,
                "Permisos",
                result.Codigo == 1 ? "SUCCESS" : "FAILED",
                $"Actualización de permisos para el rol {idRol}: {result.Mensaje}");

            return result.Codigo == 1 ? Ok(result) : BadRequest(result);
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
                "Permisos",
                "DENIED",
                $"Intento no autorizado de {operation} con permiso {permissionCode}.");

            return StatusCode(
                StatusCodes.Status403Forbidden,
                new { message = "No tiene permisos para realizar esta acción." });
        }
    }
}

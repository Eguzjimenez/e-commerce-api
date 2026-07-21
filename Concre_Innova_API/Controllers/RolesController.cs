using Microsoft.AspNetCore.Mvc;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Domain.Constants;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RolesController : ControllerBase
    {
        private readonly IRoleService _roleService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;
        private readonly IPermissionService _permissionService;

        public RolesController(
            IRoleService roleService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService,
            IPermissionService permissionService)
        {
            _roleService = roleService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
            _permissionService = permissionService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<RoleResponseDto>>> GetRoles()
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.RoleId.HasValue)
                return Unauthorized(new { message = "Debe iniciar sesion para acceder a este recurso." });

            var hasPermission = await _permissionService.RoleHasPermissionAsync(
                userContext.RoleId.Value,
                PermissionCodes.RolesVer);

            if (!hasPermission)
            {
                await _auditService.RecordAsync(
                    userContext,
                    "Roles",
                    "DENIED",
                    "Intento no autorizado de consultar roles.");

                return StatusCode(
                    StatusCodes.Status403Forbidden,
                    new { message = "No tiene permisos para consultar roles." });
            }

            await _auditService.RecordAsync(
                userContext,
                "Roles",
                "ACCESS",
                "Consulta del catalogo de roles.");

            var roles = await _roleService.GetRolesAsync();
            return Ok(roles);
        }
    }
}

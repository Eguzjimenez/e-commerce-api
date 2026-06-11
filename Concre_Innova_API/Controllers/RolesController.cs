using Microsoft.AspNetCore.Mvc;
using Concre_Innova_API.Services.Role;
using Concre_Innova_API.Models.DTOs.Responses;
using Concre_Innova_API.Security;
using Concre_Innova_API.Services.Audit;
using Concre_Innova_API.Services.Security;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RolesController : ControllerBase
    {
        private readonly IRoleService _roleService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;

        public RolesController(
            IRoleService roleService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService)
        {
            _roleService = roleService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<RoleResponseDto>>> GetRoles()
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated)
                return Unauthorized(new { message = "Debe iniciar sesion para acceder a este recurso." });

            if (userContext.RoleId != AppRoles.Administrador)
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

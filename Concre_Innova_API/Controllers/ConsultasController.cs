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
    public class ConsultasController : ControllerBase
    {
        private readonly IConsultaService _consultaService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IPermissionService _permissionService;
        private readonly IAuditService _auditService;

        public ConsultasController(
            IConsultaService consultaService,
            IRequestUserContextService requestUserContextService,
            IPermissionService permissionService,
            IAuditService auditService)
        {
            _consultaService = consultaService;
            _requestUserContextService = requestUserContextService;
            _permissionService = permissionService;
            _auditService = auditService;
        }

        [HttpGet]
        public async Task<ActionResult<PaginatedResponseDto<MensajeContactoResponseDto>>> ObtenerConsultas(
            [FromQuery] string? estado = null,
            [FromQuery] int? pagina = null,
            [FromQuery] int? tamanoPagina = null)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.ConsultasVer, "READ");
            if (denied != null)
                return denied;

            var pagination = new PaginationQuery(pagina, tamanoPagina, defaultPageSize: 20);
            var consultas = await _consultaService.ObtenerAsync(estado, pagination);

            return Ok(consultas);
        }

        [HttpPost("{idConsulta:int}/respuesta")]
        public async Task<ActionResult<OperacionResponseDto>> ResponderConsulta(
            int idConsulta,
            [FromBody] ResponderConsultaRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(
                userContext,
                PermissionCodes.ConsultasResponder,
                "REPLY");

            if (denied != null)
                return denied;

            var resultado = await _consultaService.ResponderAsync(
                idConsulta,
                request,
                userContext.UserId ?? 0);

            if (resultado.Codigo != 1)
                return BadRequest(resultado);

            await _auditService.RecordAsync(
                userContext,
                "MensajesContacto",
                "REPLY",
                $"Consulta #{idConsulta} respondida.");

            return Ok(resultado);
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
                "MensajesContacto",
                "DENIED",
                $"Intento no autorizado de {operation} con permiso {permissionCode}.");

            return StatusCode(
                StatusCodes.Status403Forbidden,
                new { message = "No tiene permisos para realizar esta acción." });
        }
    }
}

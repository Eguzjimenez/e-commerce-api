using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Security;
using Concre_Innova_API.Domain.Constants;
using Microsoft.AspNetCore.Mvc;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EmpresaController : ControllerBase
    {
        private readonly IEmpresaService _empresaService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;
        private readonly IPermissionService _permissionService;

        public EmpresaController(
            IEmpresaService empresaService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService,
            IPermissionService permissionService)
        {
            _empresaService = empresaService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
            _permissionService = permissionService;
        }

        [HttpGet("informacion")]
        public async Task<ActionResult> ObtenerInformacion()
        {
            try
            {
                var informacion = await _empresaService.ObtenerInformacionAsync();

                if (informacion is null)
                    return NotFound(new { message = "No hay informacion de la empresa registrada." });

                return Ok(informacion);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener la informacion de la empresa.", error = ex.Message });
            }
        }

        [HttpPut("informacion")]
        public async Task<ActionResult> ActualizarInformacion(
            [FromBody] ActualizarInformacionEmpresaRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, "UPDATE");
            if (denied != null)
                return denied;

            try
            {
                var resultado = await _empresaService.ActualizarInformacionAsync(
                    request,
                    userContext.UserId ?? 0);

                if (resultado.Codigo == 1)
                {
                    await _auditService.RecordAsync(
                        userContext,
                        "Empresa",
                        "SUCCESS",
                        "Informacion de la empresa actualizada.");

                    return Ok(resultado);
                }

                return BadRequest(resultado);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al actualizar la informacion de la empresa.", error = ex.Message });
            }
        }

        [HttpPost("contacto")]
        public async Task<ActionResult> EnviarMensaje([FromBody] CrearMensajeContactoRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            try
            {
                var resultado = await _empresaService.RegistrarMensajeAsync(
                    request,
                    userContext.UserId);

                if (resultado.Codigo == 1)
                    return Ok(resultado);

                return BadRequest(resultado);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al enviar el mensaje de contacto.", error = ex.Message });
            }
        }

        [HttpGet("mensajes")]
        public async Task<ActionResult> ObtenerMensajes(
            [FromQuery] string? estado = null,
            [FromQuery] int? pagina = null,
            [FromQuery] int? tamanoPagina = null)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, "READ");
            if (denied != null)
                return denied;

            try
            {
                var pagination = new PaginationQuery(pagina, tamanoPagina, defaultPageSize: 20);
                var mensajes = await _empresaService.ObtenerMensajesAsync(estado, pagination);

                return Ok(mensajes);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener los mensajes de contacto.", error = ex.Message });
            }
        }

        private async Task<ActionResult?> RequirePermissionAsync(
            RequestUserContext userContext,
            string operation)
        {
            if (!userContext.IsAuthenticated || !userContext.RoleId.HasValue)
                return Unauthorized(new { message = "Debe iniciar sesion para acceder a este recurso." });

            var hasPermission = await _permissionService.RoleHasPermissionAsync(
                userContext.RoleId.Value,
                PermissionCodes.EmpresaGestionar);

            if (hasPermission)
                return null;

            await _auditService.RecordAsync(
                userContext,
                "Empresa",
                "DENIED",
                $"Intento no autorizado de {operation} con permiso {PermissionCodes.EmpresaGestionar}.");

            return StatusCode(
                StatusCodes.Status403Forbidden,
                new { message = "No tiene permisos para realizar esta accion." });
        }
    }
}

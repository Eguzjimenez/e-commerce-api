using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Security;
using Concre_Innova_API.Domain.Constants;
using Microsoft.AspNetCore.Mvc;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EstadisticasController : ControllerBase
    {
        private readonly IEstadisticasService _estadisticasService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;
        private readonly IPermissionService _permissionService;

        public EstadisticasController(
            IEstadisticasService estadisticasService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService,
            IPermissionService permissionService)
        {
            _estadisticasService = estadisticasService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
            _permissionService = permissionService;
        }

        [HttpGet("resumen")]
        public async Task<ActionResult> ObtenerResumen()
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, "ACCESS");
            if (denied != null)
                return denied;

            try
            {
                var resumen = await _estadisticasService.ObtenerResumenAsync();
                return Ok(resumen);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener el resumen de estadisticas.", error = ex.Message });
            }
        }

        [HttpGet("dashboard")]
        public async Task<ActionResult> ObtenerDashboard()
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, "ACCESS");
            if (denied != null)
                return denied;

            try
            {
                var dashboard = await _estadisticasService.ObtenerDashboardAsync();
                return Ok(dashboard);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener los indicadores del panel.", error = ex.Message });
            }
        }

        [HttpGet("clientes-frecuentes")]
        public async Task<ActionResult> ObtenerClientesFrecuentes([FromQuery] int top = 10)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, "ACCESS");
            if (denied != null)
                return denied;

            try
            {
                var clientes = await _estadisticasService.ObtenerClientesFrecuentesAsync(top);
                return Ok(clientes);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener los clientes frecuentes.", error = ex.Message });
            }
        }

        [HttpGet("categorias")]
        public async Task<ActionResult> ObtenerPorCategoria()
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, "ACCESS");
            if (denied != null)
                return denied;

            try
            {
                var categorias = await _estadisticasService.ObtenerPorCategoriaAsync();
                return Ok(categorias);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener las estadisticas por categoria.", error = ex.Message });
            }
        }

        [HttpGet("productos-destacados")]
        public async Task<ActionResult> ObtenerProductosDestacados([FromQuery] int top = 5)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, "ACCESS");
            if (denied != null)
                return denied;

            try
            {
                var productos = await _estadisticasService.ObtenerProductosDestacadosAsync(top);
                return Ok(productos);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener los productos destacados.", error = ex.Message });
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
                PermissionCodes.EstadisticasVer);

            if (hasPermission)
                return null;

            await _auditService.RecordAsync(
                userContext,
                "Estadisticas",
                "DENIED",
                $"Intento no autorizado de {operation} con permiso {PermissionCodes.EstadisticasVer}.");

            return StatusCode(
                StatusCodes.Status403Forbidden,
                new { message = "No tiene permisos para realizar esta accion." });
        }
    }
}

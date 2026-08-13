using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Security;
using Concre_Innova_API.Domain.Constants;
using Microsoft.AspNetCore.Mvc;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ReportesController : ControllerBase
    {
        private readonly IReporteService _reporteService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;
        private readonly IPermissionService _permissionService;

        public ReportesController(
            IReporteService reporteService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService,
            IPermissionService permissionService)
        {
            _reporteService = reporteService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
            _permissionService = permissionService;
        }

        [HttpGet("ventas")]
        public async Task<ActionResult> ObtenerVentas(
            [FromQuery] DateTime? fechaDesde = null,
            [FromQuery] DateTime? fechaHasta = null,
            [FromQuery] int? idCategoria = null)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, "READ");
            if (denied != null)
                return denied;

            try
            {
                var query = new ReporteVentasQuery
                {
                    FechaDesde = fechaDesde ?? DateTime.Today.AddDays(-30),
                    FechaHasta = fechaHasta ?? DateTime.Today,
                    IdCategoria = idCategoria
                };

                var reporte = await _reporteService.ObtenerVentasPorPeriodoAsync(query);

                await _auditService.RecordAsync(
                    userContext,
                    "Reportes",
                    "ACCESS",
                    $"Consulta de reporte de ventas del {query.FechaDesde:yyyy-MM-dd} al {query.FechaHasta:yyyy-MM-dd}.");

                return Ok(reporte);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al generar el reporte de ventas.", error = ex.Message });
            }
        }

        [HttpGet("comparativo")]
        public async Task<ActionResult> ObtenerComparativo(
            [FromQuery] DateTime periodoADesde,
            [FromQuery] DateTime periodoAHasta,
            [FromQuery] DateTime periodoBDesde,
            [FromQuery] DateTime periodoBHasta)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, "READ");
            if (denied != null)
                return denied;

            try
            {
                var query = new ReporteComparativoQuery
                {
                    PeriodoADesde = periodoADesde,
                    PeriodoAHasta = periodoAHasta,
                    PeriodoBDesde = periodoBDesde,
                    PeriodoBHasta = periodoBHasta
                };

                var comparativo = await _reporteService.ObtenerComparativoAsync(query);
                return Ok(comparativo);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al generar el comparativo de periodos.", error = ex.Message });
            }
        }

        [HttpGet("productos-mas-vendidos")]
        public async Task<ActionResult> ObtenerProductosMasVendidos(
            [FromQuery] DateTime? fechaDesde = null,
            [FromQuery] DateTime? fechaHasta = null,
            [FromQuery] int top = 10)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, "READ");
            if (denied != null)
                return denied;

            try
            {
                var productos = await _reporteService.ObtenerProductosMasVendidosAsync(
                    fechaDesde ?? DateTime.Today.AddDays(-30),
                    fechaHasta ?? DateTime.Today,
                    top);

                return Ok(productos);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener los productos mas vendidos.", error = ex.Message });
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
                PermissionCodes.ReportesVer);

            if (hasPermission)
                return null;

            await _auditService.RecordAsync(
                userContext,
                "Reportes",
                "DENIED",
                $"Intento no autorizado de {operation} con permiso {PermissionCodes.ReportesVer}.");

            return StatusCode(
                StatusCodes.Status403Forbidden,
                new { message = "No tiene permisos para realizar esta accion." });
        }
    }
}

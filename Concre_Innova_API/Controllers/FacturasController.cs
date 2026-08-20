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
    public class FacturasController : ControllerBase
    {
        private const int TamanoPaginaPorDefecto = 10;

        private readonly IFacturaService _facturaService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;
        private readonly IPermissionService _permissionService;

        public FacturasController(
            IFacturaService facturaService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService,
            IPermissionService permissionService)
        {
            _facturaService = facturaService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
            _permissionService = permissionService;
        }

        /// <summary>
        /// Facturas con su estado de cobro (pagada, pendiente, vencida o en
        /// revision), paginadas y con los totales del filtro aplicado.
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<FacturaListadoResponseDto>> Obtener(
            [FromQuery] string? busqueda,
            [FromQuery] string? estado,
            [FromQuery] DateTime? desde,
            [FromQuery] DateTime? hasta,
            [FromQuery] int? pagina,
            [FromQuery] int? tamanoPagina,
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.FacturasVer, "READ");
            if (denied != null)
                return denied;

            var query = new FacturaQuery
            {
                Busqueda = busqueda,
                Estado = estado,
                Desde = desde,
                Hasta = hasta
            };

            var paginacion = new PaginationQuery(pagina, tamanoPagina, TamanoPaginaPorDefecto);

            return Ok(await _facturaService.BuscarAsync(query, paginacion, cancellationToken));
        }

        [HttpGet("{idVenta:int}")]
        public async Task<ActionResult<FacturaDetalleResponseDto>> ObtenerDetalle(
            int idVenta,
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.FacturasVer, "READ");
            if (denied != null)
                return denied;

            var detalle = await _facturaService.ObtenerDetalleAsync(idVenta, cancellationToken);

            if (detalle is null)
                return NotFound(new { message = "La factura indicada no existe." });

            return Ok(detalle);
        }

        [HttpPut("{idVenta:int}/estado")]
        public async Task<ActionResult<OperacionResponseDto>> ActualizarEstado(
            int idVenta,
            [FromBody] ActualizarEstadoFacturaRequest request,
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(
                userContext, PermissionCodes.FacturasGestionar, "UPDATE");
            if (denied != null)
                return denied;

            if (request is null)
                return BadRequest(new { message = "Los datos de la factura son requeridos." });

            // La URL manda sobre el cuerpo.
            request.IdVenta = idVenta;

            var resultado = await _facturaService.ActualizarEstadoAsync(
                request, userContext.UserId!.Value, cancellationToken);

            if (resultado.Codigo != 1)
                return BadRequest(resultado);

            return Ok(resultado);
        }

        private async Task<ActionResult?> RequirePermissionAsync(
            RequestUserContext userContext,
            string permissionCode,
            string operation)
        {
            if (!userContext.IsAuthenticated || !userContext.RoleId.HasValue || !userContext.UserId.HasValue)
                return Unauthorized(new { message = "Debe iniciar sesion para acceder a este recurso." });

            var hasPermission = await _permissionService.RoleHasPermissionAsync(
                userContext.RoleId.Value, permissionCode);

            if (hasPermission)
                return null;

            await _auditService.RecordAsync(
                userContext, "Ventas", "DENIED",
                $"Intento no autorizado de {operation} con permiso {permissionCode}.");

            return StatusCode(
                StatusCodes.Status403Forbidden,
                new { message = "No tiene permisos para realizar esta accion." });
        }
    }
}

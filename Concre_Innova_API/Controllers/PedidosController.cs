using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Security;
using Concre_Innova_API.Domain.Constants;
using Microsoft.AspNetCore.Mvc;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PedidosController : ControllerBase
    {
        private readonly IPedidoAdminService _pedidoAdminService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;
        private readonly IPermissionService _permissionService;

        public PedidosController(
            IPedidoAdminService pedidoAdminService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService,
            IPermissionService permissionService)
        {
            _pedidoAdminService = pedidoAdminService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
            _permissionService = permissionService;
        }

        [HttpGet]
        public async Task<ActionResult> ObtenerPedidos(
            [FromQuery] string? busqueda = null,
            [FromQuery] string? estado = null,
            [FromQuery] DateTime? fechaDesde = null,
            [FromQuery] DateTime? fechaHasta = null,
            [FromQuery] int? pagina = null,
            [FromQuery] int? tamanoPagina = null)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.PedidosVer, "ACCESS");
            if (denied != null)
                return denied;

            try
            {
                var query = new PedidoAdminQuery
                {
                    Busqueda = busqueda,
                    Estado = estado,
                    FechaDesde = fechaDesde,
                    FechaHasta = fechaHasta
                };

                var pagination = new PaginationQuery(pagina, tamanoPagina, defaultPageSize: 10);
                var pedidos = await _pedidoAdminService.ObtenerPedidosAsync(query, pagination);

                await _auditService.RecordAsync(
                    userContext,
                    "Pedidos",
                    "ACCESS",
                    "Consulta del listado de pedidos.");

                return Ok(pedidos);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener los pedidos." });
            }
        }

        [HttpGet("{idPedido:int}")]
        public async Task<ActionResult> ObtenerDetalle(int idPedido)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.PedidosVer, "ACCESS");
            if (denied != null)
                return denied;

            try
            {
                var detalle = await _pedidoAdminService.ObtenerDetalleAsync(idPedido);

                if (detalle is null)
                    return NotFound(new { message = "Pedido no encontrado." });

                await _auditService.RecordAsync(
                    userContext,
                    "Pedidos",
                    "ACCESS",
                    $"Consulta del detalle del pedido {idPedido}.");

                return Ok(detalle);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener el detalle del pedido." });
            }
        }

        [HttpPut("{idPedido:int}/estado")]
        public async Task<ActionResult> ActualizarEstado(
            int idPedido,
            [FromBody] ActualizarEstadoPedidoRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.PedidosActualizar, "UPDATE");
            if (denied != null)
                return denied;

            if (request == null || idPedido != request.IdPedido)
                return BadRequest(new { message = "El ID del pedido en la URL no coincide con el del cuerpo de la solicitud." });

            await _auditService.RecordAsync(
                userContext,
                "Pedidos",
                "UPDATE",
                $"Intento de actualizar estado del pedido ID: {idPedido}");

            try
            {
                var resultado = await _pedidoAdminService.ActualizarEstadoAsync(
                    idPedido,
                    request.NuevoEstado,
                    userContext.UserId ?? 0);

                if (resultado.Exitoso)
                {
                    await _auditService.RecordAsync(
                        userContext,
                        "Pedidos",
                        "SUCCESS",
                        $"Pedido ID: {idPedido} actualizado exitosamente.");

                    return Ok(resultado);
                }

                await _auditService.RecordAsync(
                    userContext,
                    "Pedidos",
                    "FAILED",
                    $"Error al actualizar pedido ID: {idPedido}. {resultado.Mensaje}");

                return BadRequest(resultado);
            }
            catch (Exception ex)
            {
                await _auditService.RecordAsync(
                    userContext,
                    "Pedidos",
                    "ERROR",
                    $"Excepcion al actualizar pedido ID: {idPedido}. {ex.Message}");

                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al actualizar el pedido." });
            }
        }

        [HttpPut("{idPedido:int}/cancelar")]
        public async Task<ActionResult> Cancelar(int idPedido)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.PedidosCancelar, "CANCEL");
            if (denied != null)
                return denied;

            await _auditService.RecordAsync(
                userContext,
                "Pedidos",
                "CANCEL",
                $"Intento de cancelar pedido ID: {idPedido}");

            try
            {
                var resultado = await _pedidoAdminService.CancelarAsync(idPedido, userContext.UserId ?? 0);

                if (resultado.Exitoso)
                {
                    await _auditService.RecordAsync(
                        userContext,
                        "Pedidos",
                        "SUCCESS",
                        $"Pedido ID: {idPedido} cancelado exitosamente.");

                    return Ok(resultado);
                }

                await _auditService.RecordAsync(
                    userContext,
                    "Pedidos",
                    "FAILED",
                    $"Error al cancelar pedido ID: {idPedido}. {resultado.Mensaje}");

                return BadRequest(resultado);
            }
            catch (Exception ex)
            {
                await _auditService.RecordAsync(
                    userContext,
                    "Pedidos",
                    "ERROR",
                    $"Excepcion al cancelar pedido ID: {idPedido}. {ex.Message}");

                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al cancelar el pedido." });
            }
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
                "Pedidos",
                "DENIED",
                $"Intento no autorizado de {operation} con permiso {permissionCode}.");

            return StatusCode(
                StatusCodes.Status403Forbidden,
                new { message = "No tiene permisos para realizar esta acción." });
        }
    }
}

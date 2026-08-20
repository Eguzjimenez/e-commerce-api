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
    public class InventarioController : ControllerBase
    {
        private const int TamanoPaginaPorDefecto = 10;

        private readonly IInventarioService _inventarioService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;
        private readonly IPermissionService _permissionService;

        public InventarioController(
            IInventarioService inventarioService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService,
            IPermissionService permissionService)
        {
            _inventarioService = inventarioService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
            _permissionService = permissionService;
        }

        /// <summary>
        /// Listado paginado de existencias con busqueda, filtro por categoria y
        /// por estado de existencias (disponible, bajo o agotado).
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<PaginatedResponseDto<InventarioItemResponseDto>>> Obtener(
            [FromQuery] string? busqueda,
            [FromQuery] int? idCategoria,
            [FromQuery] string? estado,
            [FromQuery] int? pagina,
            [FromQuery] int? tamanoPagina,
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.InventarioVer, "READ");
            if (denied != null)
                return denied;

            var query = new InventarioQuery
            {
                Busqueda = busqueda,
                IdCategoria = idCategoria,
                Estado = estado
            };

            var paginacion = new PaginationQuery(pagina, tamanoPagina, TamanoPaginaPorDefecto);
            var resultado = await _inventarioService.BuscarAsync(query, paginacion, cancellationToken);

            return Ok(resultado);
        }

        [HttpGet("{idProducto:int}")]
        public async Task<ActionResult<InventarioDetalleResponseDto>> ObtenerDetalle(
            int idProducto,
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.InventarioVer, "READ");
            if (denied != null)
                return denied;

            var detalle = await _inventarioService.ObtenerDetalleAsync(idProducto, cancellationToken);

            if (detalle is null)
                return NotFound(new { message = "El producto indicado no existe." });

            return Ok(detalle);
        }

        [HttpPut("{idProducto:int}")]
        public async Task<ActionResult<OperacionResponseDto>> Actualizar(
            int idProducto,
            [FromBody] ActualizarInventarioRequest request,
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(
                userContext,
                PermissionCodes.InventarioActualizar,
                "UPDATE");
            if (denied != null)
                return denied;

            if (request is null)
                return BadRequest(new { message = "Los datos del ajuste son requeridos." });

            // La URL manda: evita que el cuerpo apunte a otro producto.
            request.IdProducto = idProducto;

            var resultado = await _inventarioService.ActualizarAsync(
                request,
                userContext.UserId!.Value,
                cancellationToken);

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
                return Unauthorized(new { message = "Debe iniciar sesión para acceder a este recurso." });

            var hasPermission = await _permissionService.RoleHasPermissionAsync(
                userContext.RoleId.Value,
                permissionCode);

            if (hasPermission)
                return null;

            await _auditService.RecordAsync(
                userContext,
                "Inventario",
                "DENIED",
                $"Intento no autorizado de {operation} con permiso {permissionCode}.");

            return StatusCode(
                StatusCodes.Status403Forbidden,
                new { message = "No tiene permisos para realizar esta acción." });
        }
    }
}

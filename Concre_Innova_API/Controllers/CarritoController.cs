using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Security;
using Concre_Innova_API.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CarritoController : ControllerBase
    {
        private readonly ICarritoService _carritoService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;

        public CarritoController(
            ICarritoService carritoService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService)
        {
            _carritoService = carritoService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
        }

        [HttpPost("validar-stock")]
        public async Task<ActionResult<ValidarStockCarritoResponseDto>> ValidarStockCarrito(
            [FromBody] ValidarStockCarritoRequest request)
        {
            if (request == null || request.Items == null || !request.Items.Any())
            {
                return BadRequest(new
                {
                    message = "El carrito est\u00E1 vac\u00EDo o la solicitud es inv\u00E1lida."
                });
            }

            var resultado = await _carritoService.ValidarStockCarritoAsync(request);

            return Ok(resultado);
        }

        [Authorize(Roles = AppRoles.RolesCompra)]
        [HttpPost("registrar-pedido")]
        public async Task<ActionResult<RegistrarPedidoResponseDto>> RegistrarPedido(
            [FromBody] RegistrarPedidoRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
            {
                return Unauthorized(new
                {
                    message = "Debe iniciar sesi\u00F3n para registrar un pedido."
                });
            }

            if (request == null || request.Items == null || !request.Items.Any())
            {
                return BadRequest(new
                {
                    message = "El carrito est\u00E1 vac\u00EDo o la solicitud es inv\u00E1lida."
                });
            }

            request.IdUsuario = userContext.UserId.Value;
            var resultado = await _carritoService.RegistrarPedidoAsync(request);

            if (resultado.Exitoso)
            {
                return Ok(resultado);
            }

            if (EsCuentaInactivaOInexistente(resultado.Mensaje))
            {
                return Unauthorized(resultado);
            }

            return BadRequest(resultado);
        }

        [Authorize(Roles = AppRoles.RolesCompra)]
        [HttpGet("mis-pedidos")]
        public async Task<ActionResult<MisPedidosResponseDto>> ObtenerMisPedidos(
            [FromQuery] DateTime? fechaDesde = null,
            [FromQuery] DateTime? fechaHasta = null)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
            {
                return Unauthorized(new
                {
                    message = "Debe iniciar sesi\u00F3n para ver sus pedidos."
                });
            }

            var resultado = await _carritoService.ObtenerMisPedidosAsync(
                userContext.UserId.Value,
                fechaDesde,
                fechaHasta);

            if (!resultado.Exitoso)
            {
                if (EsCuentaInactivaOInexistente(resultado.Mensaje))
                {
                    return Unauthorized(resultado);
                }

                return BadRequest(resultado);
            }

            await _auditService.RecordAsync(
                userContext,
                "Pedidos",
                "ACCESS",
                $"Consulta de pedidos del usuario {userContext.UserId.Value}. " +
                $"Rango: {fechaDesde:yyyy-MM-dd} - {fechaHasta:yyyy-MM-dd}.");

            return Ok(resultado);
        }

        [Authorize(Roles = AppRoles.RolesCompra)]
        [HttpPost("mis-pedidos/{idPedido:int}/recompra")]
        public async Task<ActionResult<RecompraPedidoResponseDto>> PrepararRecompraPedido(
            int idPedido)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
            {
                return Unauthorized(new
                {
                    message = "Debe iniciar sesi\u00F3n para volver a comprar."
                });
            }

            var resultado = await _carritoService.PrepararRecompraPedidoAsync(
                userContext.UserId.Value,
                idPedido);

            if (!resultado.Exitoso)
            {
                if (EsCuentaInactivaOInexistente(resultado.Mensaje))
                {
                    return Unauthorized(resultado);
                }

                return BadRequest(resultado);
            }

            await _auditService.RecordAsync(
                userContext,
                "Pedidos",
                "REORDER",
                $"Preparaci\u00F3n de recompra del pedido #{idPedido}.");

            return Ok(resultado);
        }

        private static bool EsCuentaInactivaOInexistente(string? mensaje)
        {
            return string.Equals(
                mensaje,
                "USUARIO_NO_EXISTE",
                StringComparison.OrdinalIgnoreCase);
        }
    }
}

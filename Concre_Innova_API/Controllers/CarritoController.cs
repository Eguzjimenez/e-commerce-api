using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Security;
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
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated)
            {
                return Unauthorized(new { message = "Debe iniciar sesión para validar el stock del carrito." });
            }

            if (request == null || request.Items == null || !request.Items.Any())
            {
                return BadRequest(new { message = "El carrito está vacío o la solicitud es inválida." });
            }

            await _auditService.RecordAsync(
                userContext,
                "Carrito",
                "VALIDATION",
                $"Validación de stock para {request.Items.Count} productos.");

            var resultado = await _carritoService.ValidarStockCarritoAsync(request);

            return Ok(resultado);
        }

        [HttpPost("registrar-pedido")]
        public async Task<ActionResult<RegistrarPedidoResponseDto>> RegistrarPedido(
            [FromBody] RegistrarPedidoRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated)
            {
                return Unauthorized(new { message = "Debe iniciar sesión para registrar un pedido." });
            }

            if (request == null || request.Items == null || !request.Items.Any())
            {
                return BadRequest(new { message = "El carrito está vacío o la solicitud es inválida." });
            }

            if (string.IsNullOrWhiteSpace(request.DireccionEntrega))
            {
                return BadRequest(new { message = "La dirección de entrega es requerida." });
            }

            if (string.IsNullOrWhiteSpace(request.MetodoPago))
            {
                return BadRequest(new { message = "El método de pago es requerido." });
            }

            var resultado = await _carritoService.RegistrarPedidoAsync(request);

            if (resultado.Exitoso)
            {
                return Ok(resultado);
            }

            return BadRequest(resultado);
        }

        [HttpGet("mis-pedidos")]
        public async Task<ActionResult<MisPedidosResponseDto>> ObtenerMisPedidos()
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
            {
                return Unauthorized(new { message = "Debe iniciar sesión para ver sus pedidos." });
            }

            await _auditService.RecordAsync(
                userContext,
                "Pedidos",
                "ACCESS",
                $"Consulta de pedidos del usuario {userContext.UserId.Value}.");

            var resultado = await _carritoService.ObtenerMisPedidosAsync(userContext.UserId.Value);

            if (!resultado.Exitoso)
            {
                return BadRequest(resultado);
            }

            return Ok(resultado);
        }
    }
}

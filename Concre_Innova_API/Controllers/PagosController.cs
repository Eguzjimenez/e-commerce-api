using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PagosController : ControllerBase
    {
        private readonly IPagoService _pagoService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;

        public PagosController(
            IPagoService pagoService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService)
        {
            _pagoService = pagoService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
        }

        /// <summary>
        /// Registra el comprobante de una transferencia SINPE Movil. El procedimiento
        /// almacenado solo acepta pedidos del propio cliente autenticado.
        /// </summary>
        [Authorize(Roles = AppRoles.RolesCompra)]
        [HttpPost("comprobante")]
        [RequestSizeLimit(ComprobantePagoRules.MaximoBytes + (256 * 1024))]
        public async Task<ActionResult<OperacionResponseDto>> RegistrarComprobante(
            [FromForm] RegistrarComprobantePagoRequest request,
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
                return Unauthorized(new { message = "Debe iniciar sesión para registrar el comprobante." });

            var resultado = await _pagoService.RegistrarComprobanteAsync(
                userContext.UserId.Value,
                request,
                cancellationToken);

            if (resultado.Codigo != 1)
                return BadRequest(resultado);

            await _auditService.RecordAsync(
                userContext,
                "Pagos",
                "CREATE",
                $"Comprobante de pago registrado para el pedido #{request.IdPedido}.");

            return Ok(resultado);
        }
    }
}

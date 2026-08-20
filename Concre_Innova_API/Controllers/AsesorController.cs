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
    public class AsesorController : ControllerBase
    {
        private readonly IAsesorService _asesorService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;

        public AsesorController(
            IAsesorService asesorService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService)
        {
            _asesorService = asesorService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
        }

        [HttpGet("cuestionario")]
        public async Task<ActionResult<AsesorCuestionarioResponseDto>> ObtenerCuestionario(
            CancellationToken cancellationToken)
        {
            try
            {
                var cuestionario = await _asesorService.ObtenerCuestionarioAsync(cancellationToken);
                return Ok(cuestionario);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible cargar el cuestionario del asesor." });
            }
        }

        [HttpPost("recomendaciones")]
        public async Task<ActionResult<AsesorRecomendacionResponseDto>> GenerarRecomendaciones(
            [FromBody] AsesorRecomendacionRequest request,
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var idUsuario = userContext.IsAuthenticated ? userContext.UserId : null;

            try
            {
                var result = await _asesorService.GenerarRecomendacionesAsync(
                    idUsuario,
                    request,
                    cancellationToken);

                return result.Exitoso ? Ok(result) : BadRequest(result);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible generar las recomendaciones." });
            }
        }

        [Authorize(Roles = AppRoles.RolesCompra)]
        [HttpDelete("respuestas")]
        public async Task<ActionResult<OperacionResponseDto>> ReiniciarCuestionario(
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
            {
                return Unauthorized(new
                {
                    message = "Debe iniciar sesión para reiniciar el cuestionario."
                });
            }

            try
            {
                await _asesorService.ReiniciarCuestionarioAsync(
                    userContext.UserId.Value,
                    cancellationToken);

                await _auditService.RecordAsync(
                    userContext,
                    "AsesorRespuestas",
                    "DELETE",
                    "Respuestas del Asesor Inteligente reiniciadas por el usuario.");

                return Ok(new OperacionResponseDto
                {
                    Codigo = 1,
                    Mensaje = "Cuestionario reiniciado correctamente."
                });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible reiniciar el cuestionario." });
            }
        }
    }
}

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
    [Authorize]
    public class NotificacionesController : ControllerBase
    {
        private const string MensajeSesionRequerida =
            "Debe iniciar sesion para consultar sus notificaciones.";

        private readonly INotificacionService _notificacionService;
        private readonly IRequestUserContextService _requestUserContextService;

        public NotificacionesController(
            INotificacionService notificacionService,
            IRequestUserContextService requestUserContextService)
        {
            _notificacionService = notificacionService;
            _requestUserContextService = requestUserContextService;
        }

        [HttpGet]
        public async Task<ActionResult<NotificacionesPaginaResponseDto>> ObtenerNotificaciones(
            [FromQuery] bool soloNoLeidas = false,
            [FromQuery] int? pagina = null,
            [FromQuery] int? tamanoPagina = null,
            CancellationToken cancellationToken = default)
        {
            var idUsuario = ObtenerIdUsuario();

            if (!idUsuario.HasValue)
                return Unauthorized(new { message = MensajeSesionRequerida });

            var pagination = new PaginationQuery(
                pagina,
                tamanoPagina,
                NotificacionLimites.TamanoPaginaPorDefecto);

            try
            {
                var notificaciones = await _notificacionService.ObtenerAsync(
                    idUsuario.Value,
                    soloNoLeidas,
                    pagination,
                    cancellationToken);

                return Ok(notificaciones);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible cargar las notificaciones." });
            }
        }

        [HttpGet("resumen")]
        public async Task<ActionResult<NotificacionResumenResponseDto>> ObtenerResumen(
            CancellationToken cancellationToken)
        {
            var idUsuario = ObtenerIdUsuario();

            if (!idUsuario.HasValue)
                return Unauthorized(new { message = MensajeSesionRequerida });

            try
            {
                var resumen = await _notificacionService.ObtenerResumenAsync(
                    idUsuario.Value,
                    cancellationToken);

                return Ok(resumen);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible cargar el resumen de notificaciones." });
            }
        }

        [HttpPut("{idNotificacion:int}/lectura")]
        public async Task<ActionResult<NotificacionOperacionResponseDto>> MarcarComoLeida(
            int idNotificacion,
            CancellationToken cancellationToken)
        {
            var idUsuario = ObtenerIdUsuario();

            if (!idUsuario.HasValue)
                return Unauthorized(new { message = MensajeSesionRequerida });

            try
            {
                var resultado = await _notificacionService.MarcarComoLeidaAsync(
                    idUsuario.Value,
                    idNotificacion,
                    cancellationToken);

                return resultado.Exitoso ? Ok(resultado) : NotFound(resultado);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible actualizar la notificacion." });
            }
        }

        [HttpPut("lectura")]
        public async Task<ActionResult<NotificacionOperacionResponseDto>> MarcarTodasComoLeidas(
            CancellationToken cancellationToken)
        {
            var idUsuario = ObtenerIdUsuario();

            if (!idUsuario.HasValue)
                return Unauthorized(new { message = MensajeSesionRequerida });

            try
            {
                var resultado = await _notificacionService.MarcarTodasComoLeidasAsync(
                    idUsuario.Value,
                    cancellationToken);

                return resultado.Exitoso ? Ok(resultado) : BadRequest(resultado);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible actualizar las notificaciones." });
            }
        }

        private int? ObtenerIdUsuario()
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            return userContext.IsAuthenticated ? userContext.UserId : null;
        }
    }
}

using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Models;
using Concre_Innova_API.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = AppRoles.RolesCompra)]
    public class VisualizacionesController : ControllerBase
    {
        private const string MensajeSesionRequerida =
            "Debe iniciar sesión para gestionar sus visualizaciones.";

        private readonly IVisualizacionService _visualizacionService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;

        public VisualizacionesController(
            IVisualizacionService visualizacionService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService)
        {
            _visualizacionService = visualizacionService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
        }

        [HttpPost("imagen-espacio")]
        [Consumes("multipart/form-data")]
        [RequestSizeLimit(VisualizacionRules.MaximoBytesSolicitud)]
        public async Task<ActionResult<ImagenEspacioResponseDto>> CargarImagenEspacio(
            IFormFile imagen,
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
                return Unauthorized(new { message = MensajeSesionRequerida });

            if (imagen is null || imagen.Length == 0)
                return BadRequest(new { message = "Selecciona una imagen de tu espacio." });

            try
            {
                var upload = await LeerImagenAsync(imagen, cancellationToken);
                var resultado = await _visualizacionService.CargarImagenEspacioAsync(
                    userContext.UserId.Value,
                    upload,
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
                    new { message = "No fue posible cargar la imagen del espacio." });
            }
        }

        [HttpPost]
        public async Task<ActionResult<GuardarVisualizacionResponseDto>> Guardar(
            [FromBody] GuardarVisualizacionRequest request,
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
                return Unauthorized(new { message = MensajeSesionRequerida });

            try
            {
                var resultado = await _visualizacionService.GuardarAsync(
                    userContext.UserId.Value,
                    request,
                    cancellationToken);

                if (!resultado.Exitoso)
                    return BadRequest(resultado);

                await _auditService.RecordAsync(
                    userContext,
                    "Visualizaciones",
                    request.IdVisualizacion.HasValue ? "UPDATE" : "CREATE",
                    $"Visualización #{resultado.IdVisualizacion} guardada con " +
                    $"{request.Productos.Count} producto(s).");

                return Ok(resultado);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible guardar la visualización." });
            }
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<VisualizacionResponseDto>>> ObtenerMias(
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
                return Unauthorized(new { message = MensajeSesionRequerida });

            try
            {
                var visualizaciones = await _visualizacionService.ObtenerPorUsuarioAsync(
                    userContext.UserId.Value,
                    cancellationToken);

                return Ok(visualizaciones);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible cargar tus visualizaciones." });
            }
        }

        [HttpGet("{idVisualizacion:int}")]
        public async Task<ActionResult<VisualizacionResponseDto>> ObtenerPorId(
            int idVisualizacion,
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
                return Unauthorized(new { message = MensajeSesionRequerida });

            try
            {
                var visualizacion = await _visualizacionService.ObtenerPorIdAsync(
                    userContext.UserId.Value,
                    idVisualizacion,
                    cancellationToken);

                if (visualizacion is null)
                    return NotFound(new { message = "La visualización no existe." });

                return Ok(visualizacion);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible cargar la visualización." });
            }
        }

        [HttpDelete("{idVisualizacion:int}")]
        public async Task<IActionResult> Eliminar(
            int idVisualizacion,
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
                return Unauthorized(new { message = MensajeSesionRequerida });

            try
            {
                var eliminada = await _visualizacionService.EliminarAsync(
                    userContext.UserId.Value,
                    idVisualizacion,
                    cancellationToken);

                if (!eliminada)
                    return NotFound(new { message = "La visualización no existe." });

                await _auditService.RecordAsync(
                    userContext,
                    "Visualizaciones",
                    "DELETE",
                    $"Visualización #{idVisualizacion} eliminada.");

                return Ok(new { message = "Visualización eliminada." });
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible eliminar la visualización." });
            }
        }

        private static async Task<ImagenEspacioUpload> LeerImagenAsync(
            IFormFile imagen,
            CancellationToken cancellationToken)
        {
            await using var stream = imagen.OpenReadStream();
            using var memory = new MemoryStream();
            await stream.CopyToAsync(memory, cancellationToken);

            return new ImagenEspacioUpload
            {
                NombreOriginal = imagen.FileName,
                TipoContenido = imagen.ContentType,
                Contenido = memory.ToArray()
            };
        }
    }
}

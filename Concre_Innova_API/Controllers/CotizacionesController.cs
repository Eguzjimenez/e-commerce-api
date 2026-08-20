using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CotizacionesController : ControllerBase
    {
        private readonly ICotizacionService _cotizacionService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;

        public CotizacionesController(
            ICotizacionService cotizacionService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService)
        {
            _cotizacionService = cotizacionService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
        }

        [Authorize(Roles = AppRoles.RolesCompra)]
        [HttpPost]
        [Consumes("multipart/form-data")]
        [RequestSizeLimit(CotizacionImagenRules.MaximoBytesSolicitud)]
        public async Task<ActionResult<CrearCotizacionResponseDto>> Crear(
            [FromForm] string? descripcion,
            [FromForm] string? preferencias,
            [FromForm] string? productosJson,
            [FromForm] List<IFormFile>? imagenes,
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
            {
                return Unauthorized(new
                {
                    message = "Debe iniciar sesión para crear una cotización."
                });
            }

            if (string.IsNullOrWhiteSpace(productosJson))
            {
                return BadRequest(new
                {
                    message = "Selecciona al menos un producto para solicitar la cotización."
                });
            }

            List<SolicitudCotizacionProductoRequestDto>? productos;
            try
            {
                productos = JsonSerializer.Deserialize<
                    List<SolicitudCotizacionProductoRequestDto>>(
                        productosJson,
                        new JsonSerializerOptions
                        {
                            PropertyNameCaseInsensitive = true
                        });
            }
            catch (JsonException)
            {
                return BadRequest(new
                {
                    message = "La lista de productos de la cotización no es válida."
                });
            }

            if (productos is null || productos.Count == 0)
            {
                return BadRequest(new
                {
                    message = "Selecciona al menos un producto para solicitar la cotización."
                });
            }

            imagenes ??= new List<IFormFile>();

            if (imagenes.Count > CotizacionImagenRules.MaximoImagenes ||
                imagenes.Any(imagen =>
                    imagen.Length > CotizacionImagenRules.MaximoBytesPorImagen))
            {
                return BadRequest(new
                {
                    message = "Puedes adjuntar hasta 5 imágenes de 5 MB cada una."
                });
            }

            var request = new CrearCotizacionRequestDto
            {
                Descripcion = descripcion ?? string.Empty,
                Preferencias = preferencias ?? string.Empty,
                Productos = productos
            };

            foreach (var imagen in imagenes)
            {
                await using var stream = imagen.OpenReadStream();
                using var memory = new MemoryStream();
                await stream.CopyToAsync(memory, cancellationToken);

                request.Imagenes.Add(new CotizacionImagenUploadDto
                {
                    NombreOriginal = imagen.FileName,
                    TipoContenido = imagen.ContentType,
                    Contenido = memory.ToArray()
                });
            }

            try
            {
                var result = await _cotizacionService.CrearAsync(
                    userContext.UserId.Value,
                    request,
                    cancellationToken);

                if (!result.Exitoso)
                {
                    if (string.Equals(
                            result.Mensaje,
                            "USUARIO_NO_EXISTE",
                            StringComparison.OrdinalIgnoreCase))
                    {
                        return Unauthorized(result);
                    }

                    return BadRequest(result);
                }

                await _auditService.RecordAsync(
                    userContext,
                    "Cotizaciones",
                    "CREATE",
                    $"Cotización {result.NumeroSeguimiento} creada con " +
                    $"{result.CantidadImagenes} imagen(es).");

                return StatusCode(StatusCodes.Status201Created, result);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new
                    {
                        message = "No fue posible guardar la cotización."
                    });
            }
        }

        [Authorize(Roles = AppRoles.RolesCompra)]
        [HttpGet("mias")]
        public async Task<ActionResult<PaginatedResponseDto<CotizacionHistorialResponseDto>>>
            ObtenerMias(
                [FromQuery] CotizacionHistorialQuery query,
                [FromQuery] int? pagina = null,
                [FromQuery] int? tamanoPagina = null,
                CancellationToken cancellationToken = default)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
            {
                return Unauthorized(new
                {
                    message = "Debe iniciar sesión para consultar sus cotizaciones."
                });
            }

            var pagination = new PaginationQuery(pagina, tamanoPagina, 10);
            var result = await _cotizacionService.ObtenerPorUsuarioAsync(
                userContext.UserId.Value,
                query,
                pagination,
                cancellationToken);

            return Ok(result);
        }

        [Authorize(Roles = AppRoles.RolesCompra)]
        [HttpPost("{idCotizacion:int}/decision")]
        public async Task<ActionResult<ActualizarCotizacionResponseDto>> Decidir(
            int idCotizacion,
            [FromBody] DecidirCotizacionRequestDto request,
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
            {
                return Unauthorized(new
                {
                    message = "Debe iniciar sesión para decidir una cotización."
                });
            }

            var result = await _cotizacionService.DecidirAsync(
                userContext.UserId.Value,
                idCotizacion,
                request,
                cancellationToken);

            if (!result.Exitoso)
            {
                return CrearRespuestaError(result);
            }

            await _auditService.RecordAsync(
                userContext,
                "Cotizaciones",
                "UPDATE",
                $"Cotización #{idCotizacion} actualizada a {result.Estado}. " +
                $"Pedido asociado: {result.IdPedido?.ToString() ?? "N/A"}.");

            return Ok(result);
        }

        [Authorize(Roles = AppRoles.RolesGestionCotizaciones)]
        [HttpGet("admin")]
        public async Task<ActionResult<PaginatedResponseDto<CotizacionHistorialResponseDto>>>
            ObtenerAdmin(
                [FromQuery] CotizacionHistorialQuery query,
                [FromQuery] int? pagina = null,
                [FromQuery] int? tamanoPagina = null,
                CancellationToken cancellationToken = default)
        {
            var pagination = new PaginationQuery(pagina, tamanoPagina, 20);
            var result = await _cotizacionService.ObtenerAdminAsync(
                query,
                pagination,
                cancellationToken);

            return Ok(result);
        }

        [Authorize(Roles = AppRoles.RolesGestionCotizaciones)]
        [HttpPut("{idCotizacion:int}/respuesta")]
        public async Task<ActionResult<ActualizarCotizacionResponseDto>> Responder(
            int idCotizacion,
            [FromBody] ResponderCotizacionRequestDto request,
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var result = await _cotizacionService.ResponderAsync(
                idCotizacion,
                request,
                cancellationToken);

            if (!result.Exitoso)
            {
                return CrearRespuestaError(result);
            }

            await _auditService.RecordAsync(
                userContext,
                "Cotizaciones",
                "UPDATE",
                $"Cotización #{idCotizacion} respondida por " +
                $"{FormatCurrency(result.Total)}.");

            return Ok(result);
        }

        [Authorize(Roles = AppRoles.RolesGestionCotizaciones)]
        [HttpPost("{idCotizacion:int}/resolucion-vendedor")]
        public async Task<ActionResult<ActualizarCotizacionResponseDto>>
            ResolverPorVendedor(
                int idCotizacion,
                [FromBody] ResolverCotizacionVendedorRequestDto request,
                CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var result = await _cotizacionService.ResolverPorVendedorAsync(
                idCotizacion,
                request,
                cancellationToken);

            if (!result.Exitoso)
            {
                return CrearRespuestaError(result);
            }

            await _auditService.RecordAsync(
                userContext,
                "Cotizaciones",
                "UPDATE",
                $"Cotización #{idCotizacion} resuelta por ventas como " +
                $"{result.Estado}.");

            return Ok(result);
        }

        [Authorize(Roles = AppRoles.RolesGestionCotizaciones)]
        [HttpPost("{idCotizacion:int}/pedido")]
        public async Task<ActionResult<ActualizarCotizacionResponseDto>>
            ConvertirEnPedido(
                int idCotizacion,
                CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var result = await _cotizacionService.ConvertirEnPedidoAsync(
                idCotizacion,
                cancellationToken);

            if (!result.Exitoso)
            {
                return CrearRespuestaError(result);
            }

            await _auditService.RecordAsync(
                userContext,
                "Cotizaciones",
                "CREATE",
                $"Cotización #{idCotizacion} convertida en pedido " +
                $"#{result.IdPedido}.");

            return Ok(result);
        }

        private ActionResult<ActualizarCotizacionResponseDto> CrearRespuestaError(
            ActualizarCotizacionResponseDto result)
        {
            var internalMessage = result.Mensaje;
            result.Mensaje = TraducirMensajeOperacion(internalMessage);

            if (internalMessage.Contains(
                    "NO_EXISTE",
                    StringComparison.OrdinalIgnoreCase) ||
                internalMessage.Contains(
                    "NO_PERTENECE",
                    StringComparison.OrdinalIgnoreCase))
            {
                return NotFound(result);
            }

            if (internalMessage.Contains(
                    "ESTADO",
                    StringComparison.OrdinalIgnoreCase) ||
                internalMessage.Contains(
                    "STOCK",
                    StringComparison.OrdinalIgnoreCase) ||
                internalMessage.Contains(
                    "PROCESADA",
                    StringComparison.OrdinalIgnoreCase) ||
                internalMessage.Contains(
                    "REQUIERE_ACEPTACION",
                    StringComparison.OrdinalIgnoreCase) ||
                internalMessage.Contains(
                    "NO_APROBADA",
                    StringComparison.OrdinalIgnoreCase))
            {
                return Conflict(result);
            }

            return BadRequest(result);
        }

        private static string TraducirMensajeOperacion(string message)
        {
            if (message.Contains("NO_PERTENECE", StringComparison.OrdinalIgnoreCase))
            {
                return "La cotización no existe o no pertenece al usuario autenticado.";
            }

            if (message.Contains("NO_EXISTE", StringComparison.OrdinalIgnoreCase))
            {
                return "La cotización solicitada no existe.";
            }

            if (message.Contains("ESTADO_INVALIDO", StringComparison.OrdinalIgnoreCase))
            {
                return "La cotización ya fue decidida o todavia no ha sido respondida.";
            }

            if (message.Contains(
                    "REQUIERE_ACEPTACION",
                    StringComparison.OrdinalIgnoreCase))
            {
                return "El cliente debe aceptar la cotización antes de que ventas pueda resolverla.";
            }

            if (message.Contains("NO_APROBADA", StringComparison.OrdinalIgnoreCase))
            {
                return "La cotización debe estar aprobada antes de convertirla en pedido.";
            }

            if (message.Contains("STOCK_INSUFICIENTE", StringComparison.OrdinalIgnoreCase))
            {
                return "Uno o mas productos cotizados ya no tienen stock suficiente.";
            }

            if (message.Contains("YA_PROCESADA", StringComparison.OrdinalIgnoreCase))
            {
                return "La cotización ya tiene un pedido asociado.";
            }

            if (message.Contains("SIN_PRODUCTOS", StringComparison.OrdinalIgnoreCase))
            {
                return "La cotización no contiene productos para crear el pedido.";
            }

            if (message.Contains("PRODUCTO_NO_DISPONIBLE", StringComparison.OrdinalIgnoreCase))
            {
                return "Uno o mas productos seleccionados no están disponibles.";
            }

            return message;
        }

        private static string FormatCurrency(decimal total)
        {
            return total.ToString("0.00", System.Globalization.CultureInfo.InvariantCulture);
        }
    }
}

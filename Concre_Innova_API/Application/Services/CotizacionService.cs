using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Models;
using Concre_Innova_API.Domain.Constants;

namespace Concre_Innova_API.Application.Services
{
    public class CotizacionService : ICotizacionService
    {
        private const int MaximoCaracteresRespuesta = 1000;
        private const int MaximoProductos = 50;
        private const int MaximaCantidadProducto = 1000;
        private const decimal MaximoImporteCotizacion = 99999999.99m;
        private const int MaximoCaracteresPreferencias = 1000;

        private readonly ICotizacionRepository _cotizacionRepository;
        private readonly IAlmacenamientoImagenCotizacion _almacenamientoImagenes;
        private readonly ICotizacionNotificationService _notificacionCorreoService;
        private readonly INotificacionEventoService _notificacionEventoService;

        public CotizacionService(
            ICotizacionRepository cotizacionRepository,
            IAlmacenamientoImagenCotizacion almacenamientoImagenes,
            ICotizacionNotificationService notificacionCorreoService,
            INotificacionEventoService notificacionEventoService)
        {
            _cotizacionRepository = cotizacionRepository;
            _almacenamientoImagenes = almacenamientoImagenes;
            _notificacionCorreoService = notificacionCorreoService;
            _notificacionEventoService = notificacionEventoService;
        }

        public async Task<CrearCotizacionResponseDto> CrearAsync(
            int idUsuario,
            CrearCotizacionRequestDto request,
            CancellationToken cancellationToken)
        {
            var validationMessage = Validar(idUsuario, request);
            if (validationMessage is not null)
            {
                return CrearError(validationMessage);
            }

            var descripcion = request.Descripcion.Trim();
            var imagenesAlmacenadas = new List<CotizacionImagenAlmacenada>();

            try
            {
                foreach (var imagen in request.Imagenes)
                {
                    var extension = Path.GetExtension(imagen.NombreOriginal).ToLowerInvariant();
                    var imagenAlmacenada = await _almacenamientoImagenes.GuardarAsync(
                        idUsuario,
                        imagen,
                        extension,
                        cancellationToken);

                    imagenesAlmacenadas.Add(imagenAlmacenada);
                }

                var result = await _cotizacionRepository.CrearAsync(
                    idUsuario,
                    descripcion,
                    request.Preferencias.Trim(),
                    request.Productos,
                    imagenesAlmacenadas,
                    cancellationToken);

                if (!result.Exitoso)
                {
                    await _almacenamientoImagenes.EliminarAsync(
                        imagenesAlmacenadas.Select(imagen => imagen.RutaArchivo),
                        cancellationToken);
                    return result;
                }

                result.Imagenes = imagenesAlmacenadas
                    .Select(imagen => new CotizacionImagenResponseDto
                    {
                        RutaArchivo = imagen.RutaArchivo,
                        NombreOriginal = imagen.NombreOriginal,
                        TipoContenido = imagen.TipoContenido,
                        TamanoBytes = imagen.TamanoBytes
                    })
                    .ToList();

                return result;
            }
            catch
            {
                await _almacenamientoImagenes.EliminarAsync(
                    imagenesAlmacenadas.Select(imagen => imagen.RutaArchivo),
                    CancellationToken.None);
                throw;
            }
        }

        public Task<PaginatedResponseDto<CotizacionHistorialResponseDto>>
            ObtenerPorUsuarioAsync(
                int idUsuario,
                CotizacionHistorialQuery query,
                PaginationQuery pagination,
                CancellationToken cancellationToken)
        {
            if (idUsuario <= 0)
            {
                return Task.FromResult(
                    new PaginatedResponseDto<CotizacionHistorialResponseDto>());
            }

            return _cotizacionRepository.ObtenerPorUsuarioAsync(
                idUsuario,
                query,
                pagination,
                cancellationToken);
        }

        public Task<PaginatedResponseDto<CotizacionHistorialResponseDto>>
            ObtenerAdminAsync(
                CotizacionHistorialQuery query,
                PaginationQuery pagination,
                CancellationToken cancellationToken)
        {
            return _cotizacionRepository.ObtenerAdminAsync(
                query,
                pagination,
                cancellationToken);
        }

        public async Task<ActualizarCotizacionResponseDto> ResponderAsync(
            int idCotizacion,
            ResponderCotizacionRequestDto request,
            CancellationToken cancellationToken)
        {
            var validationMessage = ValidarRespuesta(idCotizacion, request);
            if (validationMessage is not null)
            {
                return CrearErrorActualizacion(validationMessage);
            }

            var result = await _cotizacionRepository.ResponderAsync(
                idCotizacion,
                request.Respuesta.Trim(),
                request.Productos,
                cancellationToken);

            await NotificarCambioAsync(result, cancellationToken);
            await NotificarClienteAsync(result, cancellationToken);
            return result;
        }

        public async Task<ActualizarCotizacionResponseDto> DecidirAsync(
            int idUsuario,
            int idCotizacion,
            DecidirCotizacionRequestDto request,
            CancellationToken cancellationToken)
        {
            if (idUsuario <= 0 || idCotizacion <= 0)
            {
                return CrearErrorActualizacion(
                    "La cotización solicitada no es válida.");
            }

            var decision = request?.Decision?.Trim();
            if (!string.Equals(decision, "Aceptar", StringComparison.OrdinalIgnoreCase) &&
                !string.Equals(decision, "Rechazar", StringComparison.OrdinalIgnoreCase))
            {
                return CrearErrorActualizacion(
                    "La decision debe ser Aceptar o Rechazar.");
            }

            var result = await _cotizacionRepository.DecidirAsync(
                idUsuario,
                idCotizacion,
                string.Equals(decision, "Aceptar", StringComparison.OrdinalIgnoreCase),
                cancellationToken);

            await NotificarCambioAsync(result, cancellationToken);
            return result;
        }

        public async Task<ActualizarCotizacionResponseDto> ResolverPorVendedorAsync(
            int idCotizacion,
            ResolverCotizacionVendedorRequestDto request,
            CancellationToken cancellationToken)
        {
            if (idCotizacion <= 0)
            {
                return CrearErrorActualizacion(
                    "La cotización solicitada no es válida.");
            }

            var decision = request?.Decision?.Trim();
            if (!string.Equals(decision, "Aprobar", StringComparison.OrdinalIgnoreCase) &&
                !string.Equals(decision, "Rechazar", StringComparison.OrdinalIgnoreCase))
            {
                return CrearErrorActualizacion(
                    "La decision debe ser Aprobar o Rechazar.");
            }

            var result = await _cotizacionRepository.ResolverPorVendedorAsync(
                idCotizacion,
                string.Equals(decision, "Aprobar", StringComparison.OrdinalIgnoreCase),
                cancellationToken);

            await NotificarCambioAsync(result, cancellationToken);
            await NotificarClienteAsync(result, cancellationToken);
            return result;
        }

        public async Task<ActualizarCotizacionResponseDto> ConvertirEnPedidoAsync(
            int idCotizacion,
            CancellationToken cancellationToken)
        {
            if (idCotizacion <= 0)
            {
                return CrearErrorActualizacion(
                    "La cotización solicitada no es válida.");
            }

            var result = await _cotizacionRepository.ConvertirEnPedidoAsync(
                idCotizacion,
                cancellationToken);

            if (result.Exitoso && result.IdPedido.HasValue)
            {
                await _notificacionEventoService.NotificarPedidoRegistradoAsync(
                    result.IdPedido.Value,
                    result.Total,
                    cancellationToken);
            }

            return result;
        }

        private Task NotificarCambioAsync(
            ActualizarCotizacionResponseDto result,
            CancellationToken cancellationToken)
        {
            return result.Exitoso && result.IdCotizacion.HasValue
                ? _notificacionCorreoService.EnviarPendientesAsync(
                    result.IdCotizacion.Value,
                    cancellationToken)
                : Task.CompletedTask;
        }

        /// <summary>
        /// Deja el aviso en la bandeja del cliente cuando la cotizacion avanza
        /// por una gestion del personal, no por la decision del propio cliente.
        /// </summary>
        private Task NotificarClienteAsync(
            ActualizarCotizacionResponseDto result,
            CancellationToken cancellationToken)
        {
            return result.Exitoso && result.IdCotizacion.HasValue
                ? _notificacionEventoService.NotificarCotizacionActualizadaAsync(
                    result.IdCotizacion.Value,
                    result.Estado,
                    cancellationToken)
                : Task.CompletedTask;
        }

        private static string? Validar(int idUsuario, CrearCotizacionRequestDto? request)
        {
            if (idUsuario <= 0)
            {
                return "El usuario de la cotización no es válido.";
            }

            if (request is null || string.IsNullOrWhiteSpace(request.Descripcion))
            {
                return "La descripción de la solicitud es requerida.";
            }

            if (request.Descripcion.Trim().Length >
                CotizacionImagenRules.MaximoCaracteresDescripcion)
            {
                return $"La descripción no puede superar " +
                       $"{CotizacionImagenRules.MaximoCaracteresDescripcion} caracteres.";
            }

            if (string.IsNullOrWhiteSpace(request.Preferencias))
            {
                return "Las preferencias de la solicitud son requeridas.";
            }

            if (request.Preferencias.Trim().Length > MaximoCaracteresPreferencias)
            {
                return $"Las preferencias no pueden superar " +
                       $"{MaximoCaracteresPreferencias} caracteres.";
            }

            if (request.Productos is null ||
                request.Productos.Count == 0 ||
                request.Productos.Count > MaximoProductos)
            {
                return $"La solicitud debe incluir entre 1 y {MaximoProductos} productos.";
            }

            if (request.Productos.GroupBy(producto => producto.IdProducto)
                .Any(group => group.Count() > 1))
            {
                return "Un producto no puede aparecer mas de una vez en la solicitud.";
            }

            if (request.Productos.Any(producto =>
                    producto.IdProducto <= 0 ||
                    producto.Cantidad <= 0 ||
                    producto.Cantidad > MaximaCantidadProducto))
            {
                return "Los productos solicitados contienen cantidades invalidas.";
            }

            if (request.Imagenes.Count == 0)
            {
                return "Adjunta al menos una imagen de referencia.";
            }

            if (request.Imagenes.Count > CotizacionImagenRules.MaximoImagenes)
            {
                return $"Solo puedes adjuntar hasta " +
                       $"{CotizacionImagenRules.MaximoImagenes} imágenes.";
            }

            foreach (var imagen in request.Imagenes)
            {
                var validationMessage = ValidarImagen(imagen);
                if (validationMessage is not null)
                {
                    return validationMessage;
                }
            }

            return null;
        }

        private static string? ValidarImagen(CotizacionImagenUploadDto imagen)
        {
            if (imagen.Contenido.Length == 0)
            {
                return $"La imagen '{imagen.NombreOriginal}' esta vacia.";
            }

            if (imagen.Contenido.LongLength > CotizacionImagenRules.MaximoBytesPorImagen)
            {
                return $"La imagen '{imagen.NombreOriginal}' supera el limite de 5 MB.";
            }

            var extension = Path.GetExtension(imagen.NombreOriginal).ToLowerInvariant();
            if (!CotizacionImagenRules.ExtensionesPermitidas.Contains(extension) ||
                !CotizacionImagenRules.TiposContenidoPermitidos.Contains(imagen.TipoContenido))
            {
                return $"La imagen '{imagen.NombreOriginal}' debe ser JPG, PNG o WebP.";
            }

            if (!TieneFirmaValida(extension, imagen.Contenido))
            {
                return $"El contenido de '{imagen.NombreOriginal}' no corresponde a una imagen válida.";
            }

            return null;
        }

        private static bool TieneFirmaValida(string extension, byte[] content)
        {
            return extension switch
            {
                ".jpg" or ".jpeg" =>
                    content.Length >= 3 &&
                    content[0] == 0xFF &&
                    content[1] == 0xD8 &&
                    content[2] == 0xFF,
                ".png" =>
                    content.Length >= 8 &&
                    content[0] == 0x89 &&
                    content[1] == 0x50 &&
                    content[2] == 0x4E &&
                    content[3] == 0x47 &&
                    content[4] == 0x0D &&
                    content[5] == 0x0A &&
                    content[6] == 0x1A &&
                    content[7] == 0x0A,
                ".webp" =>
                    content.Length >= 12 &&
                    content[0] == 0x52 &&
                    content[1] == 0x49 &&
                    content[2] == 0x46 &&
                    content[3] == 0x46 &&
                    content[8] == 0x57 &&
                    content[9] == 0x45 &&
                    content[10] == 0x42 &&
                    content[11] == 0x50,
                _ => false
            };
        }

        private static CrearCotizacionResponseDto CrearError(string message)
        {
            return new CrearCotizacionResponseDto
            {
                Exitoso = false,
                Mensaje = message
            };
        }

        private static string? ValidarRespuesta(
            int idCotizacion,
            ResponderCotizacionRequestDto? request)
        {
            if (idCotizacion <= 0)
            {
                return "La cotización solicitada no es válida.";
            }

            if (request is null || string.IsNullOrWhiteSpace(request.Respuesta))
            {
                return "La respuesta para el cliente es requerida.";
            }

            if (request.Respuesta.Trim().Length > MaximoCaracteresRespuesta)
            {
                return $"La respuesta no puede superar {MaximoCaracteresRespuesta} caracteres.";
            }

            if (request.Productos is null ||
                request.Productos.Count == 0 ||
                request.Productos.Count > MaximoProductos)
            {
                return $"La cotización debe incluir entre 1 y {MaximoProductos} productos.";
            }

            if (request.Productos.GroupBy(producto => producto.IdProducto)
                .Any(group => group.Count() > 1))
            {
                return "Un producto no puede aparecer mas de una vez en la cotización.";
            }

            if (request.Productos.Any(producto =>
                    producto.IdProducto <= 0 ||
                    producto.Cantidad <= 0 ||
                    producto.Cantidad > MaximaCantidadProducto ||
                    producto.PrecioUnitario <= 0 ||
                    producto.PrecioUnitario > MaximoImporteCotizacion))
            {
                return "Los productos cotizados contienen cantidades o precios invalidos.";
            }

            var total = request.Productos.Sum(
                producto => producto.PrecioUnitario * producto.Cantidad);
            if (total > MaximoImporteCotizacion)
            {
                return $"El total de la cotización no puede superar " +
                       $"{MaximoImporteCotizacion:0.00}.";
            }

            return null;
        }

        private static ActualizarCotizacionResponseDto CrearErrorActualizacion(
            string message)
        {
            return new ActualizarCotizacionResponseDto
            {
                Exitoso = false,
                Mensaje = message
            };
        }
    }
}

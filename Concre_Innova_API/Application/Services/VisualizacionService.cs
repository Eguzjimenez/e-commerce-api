using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Interfaces.Validators;
using Concre_Innova_API.Application.Models;

namespace Concre_Innova_API.Application.Services
{
    public class VisualizacionService : IVisualizacionService
    {
        private readonly IVisualizacionRepository _visualizacionRepository;
        private readonly IAlmacenamientoImagenEspacio _almacenamientoImagenEspacio;
        private readonly IVisualizacionRequestValidator _visualizacionRequestValidator;

        public VisualizacionService(
            IVisualizacionRepository visualizacionRepository,
            IAlmacenamientoImagenEspacio almacenamientoImagenEspacio,
            IVisualizacionRequestValidator visualizacionRequestValidator)
        {
            _visualizacionRepository = visualizacionRepository;
            _almacenamientoImagenEspacio = almacenamientoImagenEspacio;
            _visualizacionRequestValidator = visualizacionRequestValidator;
        }

        public async Task<ImagenEspacioResponseDto> CargarImagenEspacioAsync(
            int idUsuario,
            ImagenEspacioUpload imagen,
            CancellationToken cancellationToken)
        {
            var extension = Path.GetExtension(imagen.NombreOriginal).ToLowerInvariant();
            var mensajeValidacion = _visualizacionRequestValidator.ValidateImagenEspacio(
                imagen,
                extension);

            if (mensajeValidacion is not null)
            {
                return new ImagenEspacioResponseDto
                {
                    Exitoso = false,
                    Mensaje = mensajeValidacion
                };
            }

            var rutaImagen = await _almacenamientoImagenEspacio.GuardarAsync(
                idUsuario,
                imagen,
                extension,
                cancellationToken);

            return new ImagenEspacioResponseDto
            {
                Exitoso = true,
                Mensaje = "Imagen del espacio cargada correctamente.",
                RutaImagenEspacio = rutaImagen
            };
        }

        public async Task<GuardarVisualizacionResponseDto> GuardarAsync(
            int idUsuario,
            GuardarVisualizacionRequest request,
            CancellationToken cancellationToken)
        {
            var mensajeValidacion = _visualizacionRequestValidator.ValidateGuardar(request);

            if (mensajeValidacion is not null)
            {
                return new GuardarVisualizacionResponseDto
                {
                    Exitoso = false,
                    Mensaje = mensajeValidacion
                };
            }

            var resultado = await _visualizacionRepository.GuardarAsync(
                idUsuario,
                request,
                cancellationToken);

            if (resultado.Exitoso)
            {
                await EliminarImagenEnDesusoAsync(
                    resultado.RutaImagenAnterior,
                    cancellationToken);
            }

            return new GuardarVisualizacionResponseDto
            {
                Exitoso = resultado.Exitoso,
                Mensaje = resultado.Exitoso
                    ? "Visualización guardada en tu perfil."
                    : TraducirMensaje(resultado.Mensaje),
                IdVisualizacion = resultado.IdVisualizacion
            };
        }

        public Task<IReadOnlyList<VisualizacionResponseDto>> ObtenerPorUsuarioAsync(
            int idUsuario,
            CancellationToken cancellationToken)
        {
            return _visualizacionRepository.ObtenerPorUsuarioAsync(
                idUsuario,
                null,
                cancellationToken);
        }

        public async Task<VisualizacionResponseDto?> ObtenerPorIdAsync(
            int idUsuario,
            int idVisualizacion,
            CancellationToken cancellationToken)
        {
            var visualizaciones = await _visualizacionRepository.ObtenerPorUsuarioAsync(
                idUsuario,
                idVisualizacion,
                cancellationToken);

            return visualizaciones.FirstOrDefault();
        }

        public async Task<bool> EliminarAsync(
            int idUsuario,
            int idVisualizacion,
            CancellationToken cancellationToken)
        {
            var (eliminada, rutaImagenEspacio) = await _visualizacionRepository.EliminarAsync(
                idUsuario,
                idVisualizacion,
                cancellationToken);

            if (eliminada)
            {
                await EliminarImagenEnDesusoAsync(rutaImagenEspacio, cancellationToken);
            }

            return eliminada;
        }

        private Task EliminarImagenEnDesusoAsync(
            string? rutaImagen,
            CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(rutaImagen))
                return Task.CompletedTask;

            return _almacenamientoImagenEspacio.EliminarAsync(
                new[] { rutaImagen },
                cancellationToken);
        }

        private static string TraducirMensaje(string mensajeInterno)
        {
            if (mensajeInterno.Contains("SIN_PRODUCTOS", StringComparison.OrdinalIgnoreCase))
                return "Agrega al menos un producto a la simulación.";

            if (mensajeInterno.Contains("PRODUCTO_NO_DISPONIBLE", StringComparison.OrdinalIgnoreCase))
                return "Uno de los productos de la simulación ya no esta disponible.";

            if (mensajeInterno.Contains("VISUALIZACION_NO_ENCONTRADA", StringComparison.OrdinalIgnoreCase))
                return "La visualización no existe o no pertenece a tu perfil.";

            if (mensajeInterno.Contains("USUARIO_NO_EXISTE", StringComparison.OrdinalIgnoreCase))
                return "La sesión no es válida. Vuelve a iniciar sesión.";

            return "No fue posible guardar la visualización.";
        }
    }
}

using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Interfaces.Validators;
using Concre_Innova_API.Domain.Constants;

namespace Concre_Innova_API.Application.Services
{
    public class AsesorService : IAsesorService
    {
        private const int RecomendacionesPorClasificacionPorDefecto = 4;
        private const int MaximoRecomendacionesPorClasificacion = 12;

        private readonly IAsesorRepository _asesorRepository;
        private readonly IAsesorRequestValidator _asesorRequestValidator;

        public AsesorService(
            IAsesorRepository asesorRepository,
            IAsesorRequestValidator asesorRequestValidator)
        {
            _asesorRepository = asesorRepository;
            _asesorRequestValidator = asesorRequestValidator;
        }

        public Task<AsesorCuestionarioResponseDto> ObtenerCuestionarioAsync(
            CancellationToken cancellationToken)
        {
            return _asesorRepository.ObtenerCuestionarioAsync(cancellationToken);
        }

        public async Task<AsesorRecomendacionResponseDto> GenerarRecomendacionesAsync(
            int? idUsuario,
            AsesorRecomendacionRequest request,
            CancellationToken cancellationToken)
        {
            var cuestionario = await _asesorRepository.ObtenerCuestionarioAsync(cancellationToken);
            var mensajeValidacion = _asesorRequestValidator.ValidateRecomendacion(
                request,
                cuestionario);

            if (mensajeValidacion is not null)
                return CrearRespuestaFallida(mensajeValidacion);

            var idsOpcionSeleccionados = request.ObtenerIdsOpcionSeleccionados();
            var productos = await _asesorRepository.GenerarRecomendacionesAsync(
                idsOpcionSeleccionados,
                NormalizarLimitePorClasificacion(request.LimitePorClasificacion),
                cancellationToken);

            return new AsesorRecomendacionResponseDto
            {
                Exitoso = true,
                Mensaje = productos.Count == 0
                    ? "Todavia no hay productos disponibles para estas respuestas."
                    : "Recomendaciones generadas correctamente.",
                RespuestasGuardadas = await GuardarRespuestasSiHayUsuarioAsync(
                    idUsuario,
                    idsOpcionSeleccionados,
                    cancellationToken),
                Grupos = AgruparPorClasificacion(productos)
            };
        }

        public Task ReiniciarCuestionarioAsync(int idUsuario, CancellationToken cancellationToken)
        {
            return _asesorRepository.LimpiarRespuestasAsync(idUsuario, cancellationToken);
        }

        private async Task<bool> GuardarRespuestasSiHayUsuarioAsync(
            int? idUsuario,
            IReadOnlyCollection<int> idsOpcionSeleccionados,
            CancellationToken cancellationToken)
        {
            if (!idUsuario.HasValue)
                return false;

            return await _asesorRepository.GuardarRespuestasAsync(
                idUsuario.Value,
                idsOpcionSeleccionados,
                cancellationToken);
        }

        private static List<AsesorGrupoRecomendacionResponseDto> AgruparPorClasificacion(
            IReadOnlyList<AsesorProductoRecomendadoResponseDto> productos)
        {
            return productos
                .GroupBy(producto => producto.Clasificacion)
                .OrderBy(grupo => ProductoClasificaciones.ObtenerPrioridad(grupo.Key))
                .Select(grupo => new AsesorGrupoRecomendacionResponseDto
                {
                    Clasificacion = grupo.Key,
                    Productos = grupo.ToList()
                })
                .ToList();
        }

        private static int NormalizarLimitePorClasificacion(int? limiteSolicitado)
        {
            if (!limiteSolicitado.HasValue || limiteSolicitado.Value <= 0)
                return RecomendacionesPorClasificacionPorDefecto;

            return Math.Min(limiteSolicitado.Value, MaximoRecomendacionesPorClasificacion);
        }

        private static AsesorRecomendacionResponseDto CrearRespuestaFallida(string mensaje)
        {
            return new AsesorRecomendacionResponseDto
            {
                Exitoso = false,
                Mensaje = mensaje
            };
        }
    }
}

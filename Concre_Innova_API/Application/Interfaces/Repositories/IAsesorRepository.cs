using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface IAsesorRepository
    {
        Task<AsesorCuestionarioResponseDto> ObtenerCuestionarioAsync(
            CancellationToken cancellationToken);

        Task<IReadOnlyList<AsesorProductoRecomendadoResponseDto>> GenerarRecomendacionesAsync(
            IReadOnlyCollection<int> idsOpcionSeleccionados,
            int limitePorClasificacion,
            CancellationToken cancellationToken);

        Task<bool> GuardarRespuestasAsync(
            int idUsuario,
            IReadOnlyCollection<int> idsOpcionSeleccionados,
            CancellationToken cancellationToken);

        Task LimpiarRespuestasAsync(int idUsuario, CancellationToken cancellationToken);
    }
}

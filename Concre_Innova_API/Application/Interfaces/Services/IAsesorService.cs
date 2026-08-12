using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface IAsesorService
    {
        Task<AsesorCuestionarioResponseDto> ObtenerCuestionarioAsync(
            CancellationToken cancellationToken);

        Task<AsesorRecomendacionResponseDto> GenerarRecomendacionesAsync(
            int? idUsuario,
            AsesorRecomendacionRequest request,
            CancellationToken cancellationToken);

        Task ReiniciarCuestionarioAsync(int idUsuario, CancellationToken cancellationToken);
    }
}

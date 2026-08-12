using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Models;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface IVisualizacionRepository
    {
        Task<VisualizacionGuardada> GuardarAsync(
            int idUsuario,
            GuardarVisualizacionRequest request,
            CancellationToken cancellationToken);

        Task<IReadOnlyList<VisualizacionResponseDto>> ObtenerPorUsuarioAsync(
            int idUsuario,
            int? idVisualizacion,
            CancellationToken cancellationToken);

        Task<(bool Eliminada, string? RutaImagenEspacio)> EliminarAsync(
            int idUsuario,
            int idVisualizacion,
            CancellationToken cancellationToken);
    }
}

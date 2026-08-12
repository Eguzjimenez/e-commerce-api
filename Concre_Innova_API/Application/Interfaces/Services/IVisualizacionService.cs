using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Models;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface IVisualizacionService
    {
        Task<ImagenEspacioResponseDto> CargarImagenEspacioAsync(
            int idUsuario,
            ImagenEspacioUpload imagen,
            CancellationToken cancellationToken);

        Task<GuardarVisualizacionResponseDto> GuardarAsync(
            int idUsuario,
            GuardarVisualizacionRequest request,
            CancellationToken cancellationToken);

        Task<IReadOnlyList<VisualizacionResponseDto>> ObtenerPorUsuarioAsync(
            int idUsuario,
            CancellationToken cancellationToken);

        Task<VisualizacionResponseDto?> ObtenerPorIdAsync(
            int idUsuario,
            int idVisualizacion,
            CancellationToken cancellationToken);

        Task<bool> EliminarAsync(
            int idUsuario,
            int idVisualizacion,
            CancellationToken cancellationToken);
    }
}

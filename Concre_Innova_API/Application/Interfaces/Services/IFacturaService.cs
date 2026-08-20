using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface IFacturaService
    {
        Task<FacturaListadoResponseDto> BuscarAsync(
            FacturaQuery query, PaginationQuery pagination, CancellationToken cancellationToken);

        Task<FacturaDetalleResponseDto?> ObtenerDetalleAsync(
            int idVenta, CancellationToken cancellationToken);

        Task<OperacionResponseDto> ActualizarEstadoAsync(
            ActualizarEstadoFacturaRequest request, int idUsuario, CancellationToken cancellationToken);
    }
}

using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface IInventarioRepository
    {
        Task<PaginatedResponseDto<InventarioItemResponseDto>> BuscarAsync(
            InventarioQuery query,
            PaginationQuery pagination,
            CancellationToken cancellationToken);

        Task<InventarioDetalleResponseDto?> ObtenerDetalleAsync(
            int idProducto,
            CancellationToken cancellationToken);

        Task<OperacionResponseDto> ActualizarAsync(
            ActualizarInventarioRequest request,
            int idUsuario,
            CancellationToken cancellationToken);
    }
}

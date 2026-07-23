using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface IPedidoAdminService
    {
        Task<PaginatedResponseDto<PedidoAdminResponseDto>> ObtenerPedidosAsync(
            PedidoAdminQuery query,
            PaginationQuery pagination);

        Task<PedidoAdminDetalleResponseDto?> ObtenerDetalleAsync(int idPedido);

        Task<OperacionPedidoResultDto> ActualizarEstadoAsync(
            int idPedido,
            string? nuevoEstado,
            int idUsuario);

        Task<OperacionPedidoResultDto> CancelarAsync(int idPedido, int idUsuario);
    }
}

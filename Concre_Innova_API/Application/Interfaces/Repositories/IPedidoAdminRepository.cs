using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface IPedidoAdminRepository
    {
        Task<PaginatedResponseDto<PedidoAdminResponseDto>> ObtenerPedidosAsync(
            PedidoAdminQuery query,
            PaginationQuery pagination);

        Task<PedidoAdminDetalleResponseDto?> ObtenerDetalleAsync(int idPedido);

        Task<OperacionPedidoResultDto> ActualizarEstadoAsync(
            int idPedido,
            string nuevoEstado,
            int idUsuario);

        Task<OperacionPedidoResultDto> CancelarAsync(int idPedido, int idUsuario);
    }

    public class OperacionPedidoResultDto
    {
        public bool Exitoso { get; set; }
        public string Mensaje { get; set; } = string.Empty;
    }
}

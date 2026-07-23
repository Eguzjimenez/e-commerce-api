using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface ICarritoService
    {
        Task<ValidarStockCarritoResponseDto> ValidarStockCarritoAsync(ValidarStockCarritoRequest request);
        Task<RegistrarPedidoResponseDto> RegistrarPedidoAsync(RegistrarPedidoRequest request);
        Task<MisPedidosResponseDto> ObtenerMisPedidosAsync(
            int idUsuario,
            DateTime? fechaDesde,
            DateTime? fechaHasta);
        Task<RecompraPedidoResponseDto> PrepararRecompraPedidoAsync(int idUsuario, int idPedido);
    }
}

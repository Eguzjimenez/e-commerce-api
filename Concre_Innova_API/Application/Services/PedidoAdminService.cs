using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;

namespace Concre_Innova_API.Application.Services
{
    public class PedidoAdminService : IPedidoAdminService
    {
        private static readonly HashSet<string> EstadosValidos = new(StringComparer.OrdinalIgnoreCase)
        {
            "Pendiente",
            "En proceso",
            "Enviado",
            "Entregado"
        };

        private readonly IPedidoAdminRepository _pedidoAdminRepository;

        public PedidoAdminService(IPedidoAdminRepository pedidoAdminRepository)
        {
            _pedidoAdminRepository = pedidoAdminRepository;
        }

        public async Task<PaginatedResponseDto<PedidoAdminResponseDto>> ObtenerPedidosAsync(
            PedidoAdminQuery query,
            PaginationQuery pagination)
        {
            return await _pedidoAdminRepository.ObtenerPedidosAsync(query, pagination);
        }

        public async Task<PedidoAdminDetalleResponseDto?> ObtenerDetalleAsync(int idPedido)
        {
            if (idPedido <= 0)
            {
                return null;
            }

            return await _pedidoAdminRepository.ObtenerDetalleAsync(idPedido);
        }

        public async Task<OperacionPedidoResultDto> ActualizarEstadoAsync(
            int idPedido,
            string? nuevoEstado,
            int idUsuario)
        {
            var estadoNormalizado = nuevoEstado?.Trim() ?? string.Empty;

            if (idPedido <= 0)
            {
                return CrearError("El pedido no es valido.");
            }

            if (!EstadosValidos.Contains(estadoNormalizado))
            {
                return CrearError("El estado indicado no es valido.");
            }

            return await _pedidoAdminRepository.ActualizarEstadoAsync(
                idPedido,
                estadoNormalizado,
                idUsuario);
        }

        public async Task<OperacionPedidoResultDto> CancelarAsync(int idPedido, int idUsuario)
        {
            if (idPedido <= 0)
            {
                return CrearError("El pedido no es valido.");
            }

            return await _pedidoAdminRepository.CancelarAsync(idPedido, idUsuario);
        }

        private static OperacionPedidoResultDto CrearError(string mensaje)
        {
            return new OperacionPedidoResultDto
            {
                Exitoso = false,
                Mensaje = mensaje
            };
        }
    }
}

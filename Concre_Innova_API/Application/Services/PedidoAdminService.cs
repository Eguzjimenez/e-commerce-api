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

        private const string EstadoCancelado = "Cancelado";

        private readonly IPedidoAdminRepository _pedidoAdminRepository;
        private readonly INotificacionEventoService _notificacionEventoService;

        public PedidoAdminService(
            IPedidoAdminRepository pedidoAdminRepository,
            INotificacionEventoService notificacionEventoService)
        {
            _pedidoAdminRepository = pedidoAdminRepository;
            _notificacionEventoService = notificacionEventoService;
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

            var resultado = await _pedidoAdminRepository.ActualizarEstadoAsync(
                idPedido,
                estadoNormalizado,
                idUsuario);

            await NotificarCambioDeEstadoAsync(resultado, idPedido, estadoNormalizado);
            return resultado;
        }

        public async Task<OperacionPedidoResultDto> CancelarAsync(int idPedido, int idUsuario)
        {
            if (idPedido <= 0)
            {
                return CrearError("El pedido no es valido.");
            }

            var resultado = await _pedidoAdminRepository.CancelarAsync(idPedido, idUsuario);

            await NotificarCambioDeEstadoAsync(resultado, idPedido, EstadoCancelado);
            return resultado;
        }

        private Task NotificarCambioDeEstadoAsync(
            OperacionPedidoResultDto resultado,
            int idPedido,
            string estado)
        {
            return resultado.Exitoso
                ? _notificacionEventoService.NotificarEstadoPedidoAsync(
                    idPedido,
                    estado,
                    CancellationToken.None)
                : Task.CompletedTask;
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

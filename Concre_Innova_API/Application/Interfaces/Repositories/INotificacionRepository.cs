using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Models;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface INotificacionRepository
    {
        Task<bool> RegistrarAsync(
            NuevaNotificacion notificacion,
            CancellationToken cancellationToken);

        Task<NotificacionesPaginaResponseDto> ObtenerAsync(
            int idUsuario,
            bool soloNoLeidas,
            PaginationQuery pagination,
            CancellationToken cancellationToken);

        Task<NotificacionResumenResponseDto> ObtenerResumenAsync(
            int idUsuario,
            CancellationToken cancellationToken);

        Task<NotificacionOperacionResponseDto> MarcarLeidaAsync(
            int idUsuario,
            int idNotificacion,
            CancellationToken cancellationToken);

        Task<NotificacionOperacionResponseDto> MarcarTodasLeidasAsync(
            int idUsuario,
            CancellationToken cancellationToken);

        Task<int?> ObtenerUsuarioDePedidoAsync(
            int idPedido,
            CancellationToken cancellationToken);

        Task<int?> ObtenerUsuarioDeCotizacionAsync(
            int idCotizacion,
            CancellationToken cancellationToken);

        Task<int?> ObtenerUsuarioDeChatAsync(
            int idChat,
            CancellationToken cancellationToken);
    }
}

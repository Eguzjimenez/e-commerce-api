using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    /// <summary>
    /// Consulta y gestion de la bandeja de notificaciones de un usuario.
    /// </summary>
    public interface INotificacionService
    {
        Task<NotificacionesPaginaResponseDto> ObtenerAsync(
            int idUsuario,
            bool soloNoLeidas,
            PaginationQuery pagination,
            CancellationToken cancellationToken);

        Task<NotificacionResumenResponseDto> ObtenerResumenAsync(
            int idUsuario,
            CancellationToken cancellationToken);

        Task<NotificacionOperacionResponseDto> MarcarComoLeidaAsync(
            int idUsuario,
            int idNotificacion,
            CancellationToken cancellationToken);

        Task<NotificacionOperacionResponseDto> MarcarTodasComoLeidasAsync(
            int idUsuario,
            CancellationToken cancellationToken);
    }
}

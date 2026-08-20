using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;

namespace Concre_Innova_API.Application.Services
{
    public class NotificacionService : INotificacionService
    {
        private readonly INotificacionRepository _notificacionRepository;

        public NotificacionService(INotificacionRepository notificacionRepository)
        {
            _notificacionRepository = notificacionRepository;
        }

        public Task<NotificacionesPaginaResponseDto> ObtenerAsync(
            int idUsuario,
            bool soloNoLeidas,
            PaginationQuery pagination,
            CancellationToken cancellationToken)
        {
            return _notificacionRepository.ObtenerAsync(
                idUsuario,
                soloNoLeidas,
                pagination,
                cancellationToken);
        }

        public Task<NotificacionResumenResponseDto> ObtenerResumenAsync(
            int idUsuario,
            CancellationToken cancellationToken)
        {
            return _notificacionRepository.ObtenerResumenAsync(idUsuario, cancellationToken);
        }

        public Task<NotificacionOperacionResponseDto> MarcarComoLeidaAsync(
            int idUsuario,
            int idNotificacion,
            CancellationToken cancellationToken)
        {
            if (idNotificacion <= 0)
            {
                return Task.FromResult(
                    CrearError("La notificación indicada no es válida."));
            }

            return _notificacionRepository.MarcarLeidaAsync(
                idUsuario,
                idNotificacion,
                cancellationToken);
        }

        public Task<NotificacionOperacionResponseDto> MarcarTodasComoLeidasAsync(
            int idUsuario,
            CancellationToken cancellationToken)
        {
            return _notificacionRepository.MarcarTodasLeidasAsync(idUsuario, cancellationToken);
        }

        private static NotificacionOperacionResponseDto CrearError(string mensaje)
        {
            return new NotificacionOperacionResponseDto
            {
                Exitoso = false,
                Mensaje = mensaje
            };
        }
    }
}

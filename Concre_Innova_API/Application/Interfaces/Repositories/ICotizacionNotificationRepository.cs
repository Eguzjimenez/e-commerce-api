using Concre_Innova_API.Application.Models;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface ICotizacionNotificationRepository
    {
        Task<IReadOnlyCollection<CotizacionNotificacionPendiente>>
            ObtenerPendientesAsync(
                int idCotizacion,
                CancellationToken cancellationToken);

        Task RegistrarResultadoAsync(
            int idCotizacionNotificacion,
            bool enviada,
            CancellationToken cancellationToken);
    }
}

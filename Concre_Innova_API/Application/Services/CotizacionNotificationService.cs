using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;

namespace Concre_Innova_API.Application.Services
{
    public class CotizacionNotificationService : ICotizacionNotificationService
    {
        private readonly ICotizacionNotificationRepository _notificationRepository;
        private readonly IEmailService _emailService;
        private readonly ILogger<CotizacionNotificationService> _logger;

        public CotizacionNotificationService(
            ICotizacionNotificationRepository notificationRepository,
            IEmailService emailService,
            ILogger<CotizacionNotificationService> logger)
        {
            _notificationRepository = notificationRepository;
            _emailService = emailService;
            _logger = logger;
        }

        public async Task EnviarPendientesAsync(
            int idCotizacion,
            CancellationToken cancellationToken)
        {
            try
            {
                var notifications =
                    await _notificationRepository.ObtenerPendientesAsync(
                        idCotizacion,
                        cancellationToken);

                foreach (var notification in notifications)
                {
                    var sent = await _emailService.SendQuotationStatusChangedAsync(
                        notification.CorreoDestino,
                        notification.NombreCliente,
                        notification.NumeroSeguimiento,
                        notification.EstadoAnterior,
                        notification.EstadoNuevo,
                        notification.FechaCambio);

                    await _notificationRepository.RegistrarResultadoAsync(
                        notification.IdCotizacionNotificacion,
                        sent,
                        CancellationToken.None);
                }
            }
            catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested)
            {
                _logger.LogInformation(
                    "El envio de notificaciones de la cotizacion {QuotationId} fue cancelado.",
                    idCotizacion);
            }
            catch (Exception exception)
            {
                _logger.LogWarning(
                    exception,
                    "No se pudieron procesar las notificaciones de la cotizacion {QuotationId}.",
                    idCotizacion);
            }
        }
    }
}

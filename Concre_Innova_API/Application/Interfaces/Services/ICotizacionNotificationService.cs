namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface ICotizacionNotificationService
    {
        Task EnviarPendientesAsync(
            int idCotizacion,
            CancellationToken cancellationToken);
    }
}

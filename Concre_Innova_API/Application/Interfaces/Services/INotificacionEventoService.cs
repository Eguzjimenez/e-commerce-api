namespace Concre_Innova_API.Application.Interfaces.Services
{
    /// <summary>
    /// Genera las notificaciones que la aplicacion emite ante eventos del negocio.
    /// Cada metodo resuelve por si mismo el usuario destinatario del evento y
    /// nunca interrumpe la operacion que lo origino.
    /// </summary>
    public interface INotificacionEventoService
    {
        Task NotificarPedidoRegistradoAsync(
            int idPedido,
            decimal total,
            CancellationToken cancellationToken);

        Task NotificarEstadoPedidoAsync(
            int idPedido,
            string estado,
            CancellationToken cancellationToken);

        Task NotificarCotizacionActualizadaAsync(
            int idCotizacion,
            string estado,
            CancellationToken cancellationToken);

        Task NotificarRespuestaDeSoporteAsync(
            int idChat,
            string mensaje,
            CancellationToken cancellationToken);
    }
}

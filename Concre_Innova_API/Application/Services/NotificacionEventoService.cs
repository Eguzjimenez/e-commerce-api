using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Models;
using Concre_Innova_API.Domain.Constants;
using System.Globalization;

namespace Concre_Innova_API.Application.Services
{
    /// <summary>
    /// Traduce los eventos del negocio en notificaciones de la bandeja del usuario.
    /// Respeta la preferencia "NotificacionesActivas" de cada cuenta y nunca
    /// interrumpe la operacion que origino el evento.
    /// </summary>
    public class NotificacionEventoService : INotificacionEventoService
    {
        private const string EstadoPedidoCancelado = "Cancelado";

        private readonly INotificacionRepository _notificacionRepository;
        private readonly IPreferenciasRepository _preferenciasRepository;
        private readonly ILogger<NotificacionEventoService> _logger;

        public NotificacionEventoService(
            INotificacionRepository notificacionRepository,
            IPreferenciasRepository preferenciasRepository,
            ILogger<NotificacionEventoService> logger)
        {
            _notificacionRepository = notificacionRepository;
            _preferenciasRepository = preferenciasRepository;
            _logger = logger;
        }

        public Task NotificarPedidoRegistradoAsync(
            int idPedido,
            decimal total,
            CancellationToken cancellationToken)
        {
            return PublicarAsync(
                token => _notificacionRepository.ObtenerUsuarioDePedidoAsync(idPedido, token),
                idUsuario => new NuevaNotificacion
                {
                    IdUsuario = idUsuario,
                    Tipo = NotificacionTipos.Pedido,
                    Titulo = "Pedido registrado",
                    Mensaje =
                        $"Tu pedido #{idPedido} se registro correctamente " +
                        $"por un total de {FormatearMonto(total)}.",
                    Enlace = NotificacionEnlaces.MisPedidos,
                    Referencia = idPedido
                },
                $"pedido {idPedido}",
                cancellationToken);
        }

        public Task NotificarEstadoPedidoAsync(
            int idPedido,
            string estado,
            CancellationToken cancellationToken)
        {
            return PublicarAsync(
                token => _notificacionRepository.ObtenerUsuarioDePedidoAsync(idPedido, token),
                idUsuario => new NuevaNotificacion
                {
                    IdUsuario = idUsuario,
                    Tipo = NotificacionTipos.Pedido,
                    Titulo = EsPedidoCancelado(estado)
                        ? "Pedido cancelado"
                        : "Actualización de tu pedido",
                    Mensaje = ConstruirMensajeEstadoPedido(idPedido, estado),
                    Enlace = NotificacionEnlaces.MisPedidos,
                    Referencia = idPedido
                },
                $"pedido {idPedido}",
                cancellationToken);
        }

        public Task NotificarCotizacionActualizadaAsync(
            int idCotizacion,
            string estado,
            CancellationToken cancellationToken)
        {
            return PublicarAsync(
                token => _notificacionRepository.ObtenerUsuarioDeCotizacionAsync(idCotizacion, token),
                idUsuario => new NuevaNotificacion
                {
                    IdUsuario = idUsuario,
                    Tipo = NotificacionTipos.Cotizacion,
                    Titulo = "Actualización de tu cotización",
                    Mensaje =
                        $"Tu cotización #{idCotizacion} cambio al estado " +
                        $"{Normalizar(estado, "actualizada")}.",
                    Enlace = NotificacionEnlaces.MisCotizaciones,
                    Referencia = idCotizacion
                },
                $"cotización {idCotizacion}",
                cancellationToken);
        }

        public Task NotificarRespuestaDeSoporteAsync(
            int idChat,
            string mensaje,
            CancellationToken cancellationToken)
        {
            return PublicarAsync(
                token => _notificacionRepository.ObtenerUsuarioDeChatAsync(idChat, token),
                idUsuario => new NuevaNotificacion
                {
                    IdUsuario = idUsuario,
                    Tipo = NotificacionTipos.Chat,
                    Titulo = "Respuesta del equipo de soporte",
                    Mensaje = Normalizar(mensaje, "Recibiste una respuesta en tu conversacion."),
                    Referencia = idChat
                },
                $"chat {idChat}",
                cancellationToken);
        }

        private async Task PublicarAsync(
            Func<CancellationToken, Task<int?>> resolverDestinatario,
            Func<int, NuevaNotificacion> construirNotificacion,
            string origen,
            CancellationToken cancellationToken)
        {
            try
            {
                var idUsuario = await resolverDestinatario(cancellationToken);

                if (!idUsuario.HasValue)
                {
                    _logger.LogInformation(
                        "No se encontró un usuario destinatario para el evento del {Origen}.",
                        origen);
                    return;
                }

                if (!await NotificacionesHabilitadasAsync(idUsuario.Value))
                    return;

                await _notificacionRepository.RegistrarAsync(
                    construirNotificacion(idUsuario.Value),
                    cancellationToken);
            }
            catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested)
            {
                _logger.LogInformation(
                    "El registro de la notificación del {Origen} fue cancelado.",
                    origen);
            }
            catch (Exception exception)
            {
                _logger.LogWarning(
                    exception,
                    "No se pudo registrar la notificación del {Origen}.",
                    origen);
            }
        }

        private async Task<bool> NotificacionesHabilitadasAsync(int idUsuario)
        {
            var preferencias = await _preferenciasRepository.ObtenerAsync(idUsuario);
            return preferencias.NotificacionesActivas;
        }

        private static string ConstruirMensajeEstadoPedido(int idPedido, string estado)
        {
            return EsPedidoCancelado(estado)
                ? $"Tu pedido #{idPedido} fue cancelado."
                : $"Tu pedido #{idPedido} cambio al estado {Normalizar(estado, "actualizado")}.";
        }

        private static bool EsPedidoCancelado(string estado)
        {
            return string.Equals(
                estado?.Trim(),
                EstadoPedidoCancelado,
                StringComparison.OrdinalIgnoreCase);
        }

        private static string FormatearMonto(decimal total)
        {
            return total.ToString("N2", CultureInfo.InvariantCulture);
        }

        private static string Normalizar(string? valor, string valorPorDefecto)
        {
            var texto = valor?.Trim();

            if (string.IsNullOrEmpty(texto))
                return valorPorDefecto;

            return texto.Length > NotificacionLimites.LongitudMensaje
                ? texto[..NotificacionLimites.LongitudMensaje]
                : texto;
        }
    }
}

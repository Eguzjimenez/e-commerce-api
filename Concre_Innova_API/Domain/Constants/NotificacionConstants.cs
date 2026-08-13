namespace Concre_Innova_API.Domain.Constants
{
    /// <summary>
    /// Valores almacenados en Notificaciones.Tipo.
    /// </summary>
    public static class NotificacionTipos
    {
        public const string Pedido = "Pedido";
        public const string Cotizacion = "Cotizacion";
        public const string Chat = "Chat";
        public const string General = "General";
    }

    /// <summary>
    /// Rutas de la aplicacion web asociadas a cada tipo de notificacion.
    /// Las notificaciones del asistente para el cliente no llevan enlace porque
    /// la conversacion se abre desde la propia interfaz.
    /// </summary>
    public static class NotificacionEnlaces
    {
        public const string MisPedidos = "/mis-pedidos";
        public const string MisCotizaciones = "/mis-cotizaciones";
        public const string ChatAdministracion = "/admin/chat";
    }

    /// <summary>
    /// Longitudes maximas aceptadas por la tabla Notificaciones.
    /// </summary>
    public static class NotificacionLimites
    {
        public const int LongitudTipo = 30;
        public const int LongitudTitulo = 150;
        public const int LongitudMensaje = 500;
        public const int LongitudEnlace = 255;
        public const int TamanoPaginaPorDefecto = 20;
    }
}

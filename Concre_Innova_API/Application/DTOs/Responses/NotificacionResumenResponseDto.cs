namespace Concre_Innova_API.Application.DTOs.Responses
{
    /// <summary>
    /// Resumen liviano usado por el indicador de notificaciones de la aplicacion web.
    /// </summary>
    public class NotificacionResumenResponseDto
    {
        public int NoLeidas { get; set; }

        public NotificacionResponseDto? UltimaNoLeida { get; set; }
    }
}

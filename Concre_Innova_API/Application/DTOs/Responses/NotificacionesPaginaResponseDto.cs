namespace Concre_Innova_API.Application.DTOs.Responses
{
    /// <summary>
    /// Pagina de la bandeja de notificaciones junto con el total pendiente de lectura.
    /// </summary>
    public class NotificacionesPaginaResponseDto : PaginatedResponseDto<NotificacionResponseDto>
    {
        public int NoLeidas { get; set; }
    }
}

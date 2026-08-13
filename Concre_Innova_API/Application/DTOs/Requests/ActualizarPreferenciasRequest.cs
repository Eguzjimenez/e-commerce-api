namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class ActualizarPreferenciasRequest
    {
        public bool NotificacionesActivas { get; set; } = true;
        public bool NotificacionesCorreo { get; set; } = true;
        public string? Tema { get; set; }
    }
}

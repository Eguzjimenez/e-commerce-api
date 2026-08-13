namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class PreferenciasUsuarioResponseDto
    {
        public int IdUsuario { get; set; }
        public bool NotificacionesActivas { get; set; }
        public bool NotificacionesCorreo { get; set; }
        public string Tema { get; set; } = "claro";
        public DateTime FechaActualizacion { get; set; }
    }
}

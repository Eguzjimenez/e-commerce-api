namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class NotificacionResponseDto
    {
        public int IdNotificacion { get; set; }

        public string Tipo { get; set; } = string.Empty;

        public string Titulo { get; set; } = string.Empty;

        public string Mensaje { get; set; } = string.Empty;

        public string? Enlace { get; set; }

        public int? Referencia { get; set; }

        public bool Leida { get; set; }

        public DateTime FechaEnvio { get; set; }

        public DateTime? FechaLectura { get; set; }
    }
}

namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class MensajeContactoResponseDto
    {
        public int IdMensaje { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Correo { get; set; } = string.Empty;
        public string Telefono { get; set; } = string.Empty;
        public string Asunto { get; set; } = string.Empty;
        public string Mensaje { get; set; } = string.Empty;
        public string Estado { get; set; } = string.Empty;
        public DateTime FechaEnvio { get; set; }
        public string Respuesta { get; set; } = string.Empty;
        public DateTime? FechaRespuesta { get; set; }
    }
}

namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class NotificacionOperacionResponseDto
    {
        public bool Exitoso { get; set; }

        public string Mensaje { get; set; } = string.Empty;

        public int NoLeidas { get; set; }
    }
}

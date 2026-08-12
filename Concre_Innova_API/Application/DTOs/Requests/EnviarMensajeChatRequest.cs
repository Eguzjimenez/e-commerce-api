namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class EnviarMensajeChatRequest
    {
        public string Mensaje { get; set; } = string.Empty;

        public string MensajeNormalizado => Mensaje.Trim();
    }
}

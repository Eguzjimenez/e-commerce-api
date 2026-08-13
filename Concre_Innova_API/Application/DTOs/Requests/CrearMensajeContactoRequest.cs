namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class CrearMensajeContactoRequest
    {
        public string? Nombre { get; set; }
        public string? Correo { get; set; }
        public string? Telefono { get; set; }
        public string? Asunto { get; set; }
        public string? Mensaje { get; set; }
    }
}

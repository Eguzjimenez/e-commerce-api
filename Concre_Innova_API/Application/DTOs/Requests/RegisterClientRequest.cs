namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class RegisterClientRequest
    {
        public string? Nombre { get; set; }
        public string? Correo { get; set; }
        public string? Telefono { get; set; }
        public string? Contrasena { get; set; }
    }
}

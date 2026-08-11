namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class UpdateUserInfoRequest
    {
        public int IdUsuario { get; set; }
        public string? Nombre { get; set; }
        public string? Apellido { get; set; }
        public string? Correo { get; set; }
        public string? Telefono { get; set; }
        public string? Direccion { get; set; }
        public string? Contrasena { get; set; }
    }
}

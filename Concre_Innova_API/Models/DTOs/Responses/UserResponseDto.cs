namespace Concre_Innova_API.Models.DTOs.Responses
{
    public class UserResponseDto
    {
        public int IdUsuario { get; set; }
        public string? Nombre { get; set; }
        public string? Apellido { get; set; }
        public string? Correo { get; set; }
        public string? Telefono { get; set; }
        public int IdRol { get; set; }
        public string? NombreRol { get; set; }
    }
}

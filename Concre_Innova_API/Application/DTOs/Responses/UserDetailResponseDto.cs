namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class UserDetailResponseDto
    {
        public int IdUsuario { get; set; }
        public string? Nombre { get; set; }
        public string? Apellido { get; set; }
        public string? Correo { get; set; }
        public string? Telefono { get; set; }
        public string? Estado { get; set; }
        public DateTime? FechaRegistro { get; set; }
        public int IdRol { get; set; }
        public string? NombreRol { get; set; }
    }
}

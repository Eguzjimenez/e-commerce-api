namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class UserInfoResponseDto
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
        public int? IdCliente { get; set; }
        public string? Direccion { get; set; }
        public string? EstadoCliente { get; set; }
        public DateTime? FechaRegistroCliente { get; set; }
    }
}

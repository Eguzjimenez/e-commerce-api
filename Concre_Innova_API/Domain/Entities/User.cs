namespace Concre_Innova_API.Domain.Entities
{
    public class User
    {
        public int Codigo { get; set; }
        public string? Mensaje { get; set; }
        public int? IdUsuario { get; set; }
        public string? Nombre { get; set; }
        public string? Apellido { get; set; }
        public string? Correo { get; set; }
        public string? Contrasena { get; set; }
        public string? Telefono { get; set; }
        public int? IdRol { get; set; }
        public string? NombreRol { get; set; }
    }
}

namespace Concre_Innova_API.Domain.Entities
{
    public class UserLogin
    {
        public int Codigo { get; set; }
        public string? Mensaje { get; set; }
        public int? IdUsuario { get; set; }
        public int? IdRol { get; set; }
        public string? NombreRol { get; set; }
        public string? Token { get; set; }
    }
}

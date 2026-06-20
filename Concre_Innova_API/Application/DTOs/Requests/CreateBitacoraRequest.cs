namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class CreateBitacoraRequest
    {
        public int IdUsuario { get; set; }
        public string? TablaAfectada { get; set; }
        public string? Operacion { get; set; }
        public string? Descripcion { get; set; }
        public string? IpUsuario { get; set; }
    }
}

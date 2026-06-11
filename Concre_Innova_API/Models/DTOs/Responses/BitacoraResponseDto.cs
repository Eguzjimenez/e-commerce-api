namespace Concre_Innova_API.Models.DTOs.Responses
{
    public class BitacoraResponseDto
    {
        public int IdBitacora { get; set; }
        public int IdUsuario { get; set; }
        public string? Correo { get; set; }        
        public string? NombreUsuario { get; set; }
        public string? TablaAfectada { get; set; }
        public string? Operacion { get; set; }
        public string? Descripcion { get; set; }
        public DateTime FechaHora { get; set; }
        public string? IpUsuario { get; set; }
    }
}

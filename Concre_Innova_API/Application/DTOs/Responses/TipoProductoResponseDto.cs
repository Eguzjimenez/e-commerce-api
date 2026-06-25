namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class TipoProductoResponseDto
    {
        public int IdTipo { get; set; }
        public string NombreTipo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Estado { get; set; } = string.Empty;
    }
}

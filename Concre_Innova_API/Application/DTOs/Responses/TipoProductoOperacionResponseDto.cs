namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class TipoProductoOperacionResponseDto
    {
        public int Codigo { get; set; }
        public string Mensaje { get; set; } = string.Empty;
        public int? IdTipo { get; set; }
    }
}

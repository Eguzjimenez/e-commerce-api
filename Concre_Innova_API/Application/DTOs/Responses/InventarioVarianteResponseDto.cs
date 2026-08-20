namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class InventarioVarianteResponseDto
    {
        public int IdVariante { get; set; }
        public string? NombreVariante { get; set; }
        public string? Tamano { get; set; }
        public string? Material { get; set; }
        public decimal Precio { get; set; }
        public int Stock { get; set; }
        public string? Estado { get; set; }
    }
}

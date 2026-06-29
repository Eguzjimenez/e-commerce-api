namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class ProductoVarianteResponseDto
    {
        public int IdVariante { get; set; }
        public int IdProducto { get; set; }
        public string NombreVariante { get; set; } = string.Empty;
        public string Tamano { get; set; } = string.Empty;
        public string Material { get; set; } = string.Empty;
        public decimal Precio { get; set; }
        public int Stock { get; set; }
        public string Imagen { get; set; } = string.Empty;
        public bool EstaDisponible { get; set; }
    }
}

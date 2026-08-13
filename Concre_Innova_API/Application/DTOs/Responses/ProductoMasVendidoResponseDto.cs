namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class ProductoMasVendidoResponseDto
    {
        public int IdProducto { get; set; }
        public string Producto { get; set; } = string.Empty;
        public string Categoria { get; set; } = string.Empty;
        public int UnidadesVendidas { get; set; }
        public decimal Ingresos { get; set; }
    }
}

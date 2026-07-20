namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class CatalogoFiltrosResponseDto
    {
        public IEnumerable<CategoriaResponseDto> Categorias { get; set; } = Array.Empty<CategoriaResponseDto>();

        public IEnumerable<TipoProductoResponseDto> TiposProducto { get; set; } = Array.Empty<TipoProductoResponseDto>();

        public decimal PrecioMinimo { get; set; }

        public decimal PrecioMaximo { get; set; }
    }
}

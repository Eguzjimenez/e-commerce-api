namespace Concre_Innova_API.Application.DTOs.Responses
{
    /// <summary>
    /// Ficha completa que alimenta la vista "Ver" del inventario.
    /// </summary>
    public class InventarioDetalleResponseDto
    {
        public int IdProducto { get; set; }
        public string? Nombre { get; set; }
        public string? Descripcion { get; set; }
        public string? EstadoProducto { get; set; }
        public decimal Precio { get; set; }
        public string? Imagen { get; set; }
        public string? Tamano { get; set; }
        public string? Material { get; set; }
        public string? Caracteristicas { get; set; }
        public int? IdCategoria { get; set; }
        public string? NombreCategoria { get; set; }
        public string? NombreTipo { get; set; }
        public int CantidadDisponible { get; set; }
        public int CantidadMinima { get; set; }
        public DateTime? FechaActualizacion { get; set; }

        public IEnumerable<InventarioVarianteResponseDto> Variantes { get; set; } =
            Array.Empty<InventarioVarianteResponseDto>();
    }
}

namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class CatalogoProductoResponseDto
    {
        public int IdProducto { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public decimal Precio { get; set; }
        public string Imagen { get; set; } = string.Empty;
        public int IdCategoria { get; set; }
        public string NombreCategoria { get; set; } = string.Empty;
        public int? IdTipo { get; set; }
        public string NombreTipo { get; set; } = string.Empty;
        public string Tamano { get; set; } = string.Empty;
        public string Material { get; set; } = string.Empty;
        public string Caracteristicas { get; set; } = string.Empty;
        public int Stock { get; set; }
        public string Disponibilidad { get; set; } = string.Empty;
    }
}

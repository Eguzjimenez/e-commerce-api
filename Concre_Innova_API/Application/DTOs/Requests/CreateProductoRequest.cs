namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class CreateProductoRequest
    {
        public string Nombre { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public decimal Precio { get; set; }
        public string Imagen { get; set; } = string.Empty;
        public int IdCategoria { get; set; }
        public string? Tamano { get; set; }
        public string? Material { get; set; }
        public int CantidadDisponible { get; set; }
        public int CantidadMinima { get; set; } = 0;
    }
}

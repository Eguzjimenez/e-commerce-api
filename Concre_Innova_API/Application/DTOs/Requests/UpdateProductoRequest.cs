namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class UpdateProductoRequest
    {
        public int IdProducto { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public decimal Precio { get; set; }
        public string? Imagen { get; set; }
        public int IdCategoria { get; set; }
        public string? Tamano { get; set; }
        public string? Material { get; set; }
        public int CantidadDisponible { get; set; }
        public int CantidadMinima { get; set; }
        public string Estado { get; set; } = string.Empty;
    }
}

namespace Concre_Innova_API.Application.DTOs.Responses
{
    /// <summary>
    /// Fila del inventario administrativo: existencias de un producto junto al
    /// minimo configurado y el estado que se deriva de ambos.
    /// </summary>
    public class InventarioItemResponseDto
    {
        public int IdProducto { get; set; }
        public string? Nombre { get; set; }
        public string? EstadoProducto { get; set; }
        public decimal Precio { get; set; }
        public string? Imagen { get; set; }
        public int? IdCategoria { get; set; }
        public string? NombreCategoria { get; set; }
        public int CantidadDisponible { get; set; }
        public int CantidadMinima { get; set; }
        public DateTime? FechaActualizacion { get; set; }
        public int TotalVariantes { get; set; }
        public string? EstadoExistencias { get; set; }
    }
}

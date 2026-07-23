namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class RecompraPedidoResponseDto
    {
        public bool Exitoso { get; set; }
        public string? Mensaje { get; set; }
        public List<RecompraPedidoItemDto> Items { get; set; } = new();
    }

    public class RecompraPedidoItemDto
    {
        public int IdProducto { get; set; }
        public int? IdVariante { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public decimal Precio { get; set; }
        public string Imagen { get; set; } = string.Empty;
        public string NombreVariante { get; set; } = string.Empty;
        public string Tamano { get; set; } = string.Empty;
        public string Material { get; set; } = string.Empty;
        public string Color { get; set; } = string.Empty;
        public int Cantidad { get; set; }
        public bool Disponible { get; set; }
        public string MotivoNoDisponible { get; set; } = string.Empty;
    }
}

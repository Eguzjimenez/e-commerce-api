namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class MisPedidosResponseDto
    {
        public bool Exitoso { get; set; }
        public string? Mensaje { get; set; }
        public List<PedidoUsuarioDto> Pedidos { get; set; } = new();
    }

    public class PedidoUsuarioDto
    {
        public int IdPedido { get; set; }
        public DateTime FechaPedido { get; set; }
        public string Estado { get; set; } = string.Empty;
        public string DireccionEntrega { get; set; } = string.Empty;
        public string MetodoPago { get; set; } = string.Empty;
        public string EstadoPago { get; set; } = string.Empty;
        public decimal Total { get; set; }
        public List<DetallePedidoUsuarioDto> Detalle { get; set; } = new();
    }

    public class DetallePedidoUsuarioDto
    {
        public int IdDetallePedido { get; set; }
        public int IdProducto { get; set; }
        public int? IdVariante { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string NombreVariante { get; set; } = string.Empty;
        public string Tamano { get; set; } = string.Empty;
        public string Material { get; set; } = string.Empty;
        public string Color { get; set; } = string.Empty;
        public string? Imagen { get; set; }
        public int Cantidad { get; set; }
        public decimal PrecioUnitario { get; set; }
        public decimal Subtotal { get; set; }
    }
}

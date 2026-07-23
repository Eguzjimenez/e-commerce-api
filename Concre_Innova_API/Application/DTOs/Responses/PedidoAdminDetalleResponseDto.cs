namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class PedidoAdminDetalleResponseDto
    {
        public int IdPedido { get; set; }
        public DateTime FechaPedido { get; set; }
        public string Estado { get; set; } = string.Empty;
        public string DireccionEntrega { get; set; } = string.Empty;
        public decimal Total { get; set; }
        public int IdCliente { get; set; }
        public string NombreCliente { get; set; } = string.Empty;
        public string CorreoCliente { get; set; } = string.Empty;
        public string TelefonoCliente { get; set; } = string.Empty;
        public string MetodoPago { get; set; } = string.Empty;
        public string EstadoPago { get; set; } = string.Empty;
        public List<DetallePedidoAdminDto> Detalle { get; set; } = new();
    }

    public class DetallePedidoAdminDto
    {
        public int IdDetallePedido { get; set; }
        public int IdProducto { get; set; }
        public int? IdVariante { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string NombreVariante { get; set; } = string.Empty;
        public string Imagen { get; set; } = string.Empty;
        public int Cantidad { get; set; }
        public decimal PrecioUnitario { get; set; }
        public decimal Subtotal { get; set; }
    }
}

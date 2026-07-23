namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class PedidoAdminResponseDto
    {
        public int IdPedido { get; set; }
        public DateTime FechaPedido { get; set; }
        public string Estado { get; set; } = string.Empty;
        public string DireccionEntrega { get; set; } = string.Empty;
        public decimal Total { get; set; }
        public int IdCliente { get; set; }
        public string NombreCliente { get; set; } = string.Empty;
        public string CorreoCliente { get; set; } = string.Empty;
        public string MetodoPago { get; set; } = string.Empty;
    }
}

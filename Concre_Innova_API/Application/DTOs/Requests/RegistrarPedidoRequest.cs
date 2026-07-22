namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class RegistrarPedidoRequest
    {
        public int IdUsuario { get; set; }
        public string DireccionEntrega { get; set; } = string.Empty;
        public string MetodoPago { get; set; } = string.Empty;
        public List<ItemCarritoRequest> Items { get; set; } = new();
    }
}

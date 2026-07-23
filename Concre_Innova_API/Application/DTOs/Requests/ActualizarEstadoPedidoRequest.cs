namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class ActualizarEstadoPedidoRequest
    {
        public int IdPedido { get; set; }
        public string? NuevoEstado { get; set; }
    }
}

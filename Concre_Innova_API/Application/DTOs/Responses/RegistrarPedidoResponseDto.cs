namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class RegistrarPedidoResponseDto
    {
        public bool Exitoso { get; set; }
        public string? Mensaje { get; set; }
        public int? IdPedido { get; set; }
        public int? IdCliente { get; set; }
        public decimal? Total { get; set; }
    }
}

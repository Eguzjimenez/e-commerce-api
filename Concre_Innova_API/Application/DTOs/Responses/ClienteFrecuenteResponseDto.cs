namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class ClienteFrecuenteResponseDto
    {
        public int IdCliente { get; set; }
        public string NombreCliente { get; set; } = string.Empty;
        public int CantidadPedidos { get; set; }
        public decimal TotalComprado { get; set; }
    }
}

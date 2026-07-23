namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class ActualizarCotizacionResponseDto
    {
        public bool Exitoso { get; set; }
        public string Mensaje { get; set; } = string.Empty;
        public int? IdCotizacion { get; set; }
        public string Estado { get; set; } = string.Empty;
        public decimal Total { get; set; }
        public int? IdPedido { get; set; }
        public List<CotizacionProductoResponseDto> Productos { get; set; } = new();
    }
}

namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class ResponderCotizacionRequestDto
    {
        public string Respuesta { get; set; } = string.Empty;
        public List<CotizacionProductoRequestDto> Productos { get; set; } = new();
    }

    public class CotizacionProductoRequestDto
    {
        public int IdProducto { get; set; }
        public int Cantidad { get; set; }
        public decimal PrecioUnitario { get; set; }
    }
}

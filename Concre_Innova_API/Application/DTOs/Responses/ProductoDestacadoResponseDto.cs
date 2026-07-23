namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class ProductoDestacadoResponseDto
    {
        public string NombreProducto { get; set; } = string.Empty;
        public int CantidadVendida { get; set; }
        public decimal PorcentajeRelativo { get; set; }
    }
}

namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class EstadisticaCategoriaResponseDto
    {
        public string NombreCategoria { get; set; } = string.Empty;
        public decimal TotalVendido { get; set; }
        public decimal PorcentajeDelTotal { get; set; }
    }
}

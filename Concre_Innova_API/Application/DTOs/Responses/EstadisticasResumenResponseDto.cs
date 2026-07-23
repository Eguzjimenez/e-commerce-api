namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class EstadisticasResumenResponseDto
    {
        public decimal VentasMesActual { get; set; }
        public decimal VariacionMesAnteriorPorcentaje { get; set; }
        public string ProductoDestacado { get; set; } = string.Empty;
        public int ClientesFrecuentes { get; set; }
    }
}

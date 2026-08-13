namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class EstadisticasDashboardResponseDto
    {
        public decimal VentasMes { get; set; }
        public int PedidosPendientes { get; set; }
        public int CotizacionesPendientes { get; set; }
        public int ProductosBajoStock { get; set; }
        public int ProductosActivos { get; set; }
        public List<VentaMensualDto> VentasMensuales { get; set; } = new();

        public decimal PorcentajeInventarioSaludable =>
            ProductosActivos > 0
                ? ((decimal)(ProductosActivos - ProductosBajoStock) / ProductosActivos) * 100
                : 0;
    }

    public class VentaMensualDto
    {
        public string Periodo { get; set; } = string.Empty;
        public decimal Ingresos { get; set; }
    }
}

namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class ReporteComparativoResponseDto
    {
        public ReportePeriodoDto PeriodoA { get; set; } = new();
        public ReportePeriodoDto PeriodoB { get; set; } = new();

        public decimal VariacionIngresosPorcentaje =>
            PeriodoA.Ingresos > 0
                ? ((PeriodoB.Ingresos - PeriodoA.Ingresos) / PeriodoA.Ingresos) * 100
                : 0;

        public decimal VariacionPedidosPorcentaje =>
            PeriodoA.Pedidos > 0
                ? ((decimal)(PeriodoB.Pedidos - PeriodoA.Pedidos) / PeriodoA.Pedidos) * 100
                : 0;
    }

    public class ReportePeriodoDto
    {
        public string Etiqueta { get; set; } = string.Empty;
        public DateTime Desde { get; set; }
        public DateTime Hasta { get; set; }
        public decimal Ingresos { get; set; }
        public int Pedidos { get; set; }
        public decimal TicketPromedio { get; set; }
    }
}

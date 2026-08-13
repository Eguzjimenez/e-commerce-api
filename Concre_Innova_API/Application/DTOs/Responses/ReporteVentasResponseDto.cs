namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class ReporteVentasResponseDto
    {
        public List<ReporteVentaItemDto> Items { get; set; } = new();
        public ReporteVentasTotalesDto Totales { get; set; } = new();
        public List<ReporteVentaPorFechaDto> SerieDiaria { get; set; } = new();
    }

    public class ReporteVentaItemDto
    {
        public DateTime Fecha { get; set; }
        public string Producto { get; set; } = string.Empty;
        public string Categoria { get; set; } = string.Empty;
        public int Unidades { get; set; }
        public int Pedidos { get; set; }
        public decimal Ingresos { get; set; }
    }

    public class ReporteVentasTotalesDto
    {
        public decimal IngresosTotales { get; set; }
        public int PedidosTotales { get; set; }
        public int UnidadesTotales { get; set; }
        public decimal TicketPromedio =>
            PedidosTotales > 0 ? IngresosTotales / PedidosTotales : 0;
    }

    public class ReporteVentaPorFechaDto
    {
        public DateTime Fecha { get; set; }
        public decimal Ingresos { get; set; }
        public int Pedidos { get; set; }
    }
}

namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class ReporteVentasQuery
    {
        public DateTime FechaDesde { get; set; }
        public DateTime FechaHasta { get; set; }
        public int? IdCategoria { get; set; }
    }
}

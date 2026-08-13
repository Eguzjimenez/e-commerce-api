namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class ReporteComparativoQuery
    {
        public DateTime PeriodoADesde { get; set; }
        public DateTime PeriodoAHasta { get; set; }
        public DateTime PeriodoBDesde { get; set; }
        public DateTime PeriodoBHasta { get; set; }
    }
}

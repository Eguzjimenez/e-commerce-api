using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;

namespace Concre_Innova_API.Application.Services
{
    public class ReporteService : IReporteService
    {
        private const int TopProductosPorDefecto = 10;
        private const int TopProductosMaximo = 50;
        private const int DiasPorDefecto = 30;

        private readonly IReporteRepository _reporteRepository;

        public ReporteService(IReporteRepository reporteRepository)
        {
            _reporteRepository = reporteRepository;
        }

        public async Task<ReporteVentasResponseDto> ObtenerVentasPorPeriodoAsync(ReporteVentasQuery query)
        {
            NormalizarRango(query);
            return await _reporteRepository.ObtenerVentasPorPeriodoAsync(query);
        }

        public async Task<ReporteComparativoResponseDto> ObtenerComparativoAsync(ReporteComparativoQuery query)
        {
            if (query.PeriodoADesde > query.PeriodoAHasta)
            {
                (query.PeriodoADesde, query.PeriodoAHasta) = (query.PeriodoAHasta, query.PeriodoADesde);
            }

            if (query.PeriodoBDesde > query.PeriodoBHasta)
            {
                (query.PeriodoBDesde, query.PeriodoBHasta) = (query.PeriodoBHasta, query.PeriodoBDesde);
            }

            return await _reporteRepository.ObtenerComparativoAsync(query);
        }

        public async Task<IEnumerable<ProductoMasVendidoResponseDto>> ObtenerProductosMasVendidosAsync(
            DateTime fechaDesde,
            DateTime fechaHasta,
            int top)
        {
            if (fechaDesde > fechaHasta)
            {
                (fechaDesde, fechaHasta) = (fechaHasta, fechaDesde);
            }

            var topValido = top <= 0
                ? TopProductosPorDefecto
                : Math.Min(top, TopProductosMaximo);

            return await _reporteRepository.ObtenerProductosMasVendidosAsync(
                fechaDesde,
                fechaHasta,
                topValido);
        }

        private static void NormalizarRango(ReporteVentasQuery query)
        {
            if (query.FechaHasta == default)
            {
                query.FechaHasta = DateTime.Today;
            }

            if (query.FechaDesde == default)
            {
                query.FechaDesde = query.FechaHasta.AddDays(-DiasPorDefecto);
            }

            if (query.FechaDesde > query.FechaHasta)
            {
                (query.FechaDesde, query.FechaHasta) = (query.FechaHasta, query.FechaDesde);
            }

            if (query.IdCategoria.HasValue && query.IdCategoria.Value <= 0)
            {
                query.IdCategoria = null;
            }
        }
    }
}

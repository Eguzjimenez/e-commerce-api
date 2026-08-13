using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface IReporteRepository
    {
        Task<ReporteVentasResponseDto> ObtenerVentasPorPeriodoAsync(ReporteVentasQuery query);
        Task<ReporteComparativoResponseDto> ObtenerComparativoAsync(ReporteComparativoQuery query);
        Task<IEnumerable<ProductoMasVendidoResponseDto>> ObtenerProductosMasVendidosAsync(
            DateTime fechaDesde,
            DateTime fechaHasta,
            int top);
    }
}

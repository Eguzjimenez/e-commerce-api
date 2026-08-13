using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;

namespace Concre_Innova_API.Application.Services
{
    public class EstadisticasService : IEstadisticasService
    {
        private const int TopClientesFrecuentesPorDefecto = 10;
        private const int TopProductosDestacadosPorDefecto = 5;

        private readonly IEstadisticasRepository _estadisticasRepository;

        public EstadisticasService(IEstadisticasRepository estadisticasRepository)
        {
            _estadisticasRepository = estadisticasRepository;
        }

        public async Task<EstadisticasResumenResponseDto> ObtenerResumenAsync()
        {
            return await _estadisticasRepository.ObtenerResumenAsync();
        }

        public async Task<EstadisticasDashboardResponseDto> ObtenerDashboardAsync()
        {
            return await _estadisticasRepository.ObtenerDashboardAsync();
        }

        public async Task<IEnumerable<ClienteFrecuenteResponseDto>> ObtenerClientesFrecuentesAsync(int top)
        {
            var topValido = top > 0 ? top : TopClientesFrecuentesPorDefecto;
            return await _estadisticasRepository.ObtenerClientesFrecuentesAsync(topValido);
        }

        public async Task<IEnumerable<EstadisticaCategoriaResponseDto>> ObtenerPorCategoriaAsync()
        {
            return await _estadisticasRepository.ObtenerPorCategoriaAsync();
        }

        public async Task<IEnumerable<ProductoDestacadoResponseDto>> ObtenerProductosDestacadosAsync(int top)
        {
            var topValido = top > 0 ? top : TopProductosDestacadosPorDefecto;
            return await _estadisticasRepository.ObtenerProductosDestacadosAsync(topValido);
        }
    }
}

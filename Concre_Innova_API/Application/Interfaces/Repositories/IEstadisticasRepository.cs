using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface IEstadisticasRepository
    {
        Task<EstadisticasResumenResponseDto> ObtenerResumenAsync();
        Task<IEnumerable<ClienteFrecuenteResponseDto>> ObtenerClientesFrecuentesAsync(int top);
        Task<IEnumerable<EstadisticaCategoriaResponseDto>> ObtenerPorCategoriaAsync();
        Task<IEnumerable<ProductoDestacadoResponseDto>> ObtenerProductosDestacadosAsync(int top);
    }
}

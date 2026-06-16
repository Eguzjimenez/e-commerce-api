using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Domain.Entities;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface IBitacoraRepository
    {
        Task<BitacoraResult> InsertBitacoraAsync(int idUsuario, string tablaAfectada, string operacion, string descripcion, string ipUsuario);
        Task<IEnumerable<BitacoraResponseDto>> GetBitacoraAsync();
    }
}

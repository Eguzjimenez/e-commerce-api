using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Domain.Entities;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface IBitacoraService
    {
        Task<BitacoraResult> InsertBitacoraAsync(int idUsuario, string tablaAfectada, string operacion, string descripcion, string ipUsuario);
        Task<IEnumerable<BitacoraResponseDto>> GetBitacoraAsync();
    }
}

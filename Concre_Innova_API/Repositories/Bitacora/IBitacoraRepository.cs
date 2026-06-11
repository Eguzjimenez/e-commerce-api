using Concre_Innova_API.Models.DTOs.Responses;
using Concre_Innova_API.Models.Entities;

namespace Concre_Innova_API.Repositories.Bitacora
{
    public interface IBitacoraRepository
    {
        Task<BitacoraResult> InsertBitacoraAsync(int idUsuario, string tablaAfectada, string operacion, string descripcion, string ipUsuario);
        Task<IEnumerable<BitacoraResponseDto>> GetBitacoraAsync();
    }
}

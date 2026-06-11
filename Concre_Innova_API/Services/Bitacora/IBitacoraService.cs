using Concre_Innova_API.Models.DTOs.Responses;
using Concre_Innova_API.Models.Entities;

namespace Concre_Innova_API.Services.Bitacora
{
    public interface IBitacoraService
    {
        Task<BitacoraResult> InsertBitacoraAsync(int idUsuario, string tablaAfectada, string operacion, string descripcion, string ipUsuario);
        Task<IEnumerable<BitacoraResponseDto>> GetBitacoraAsync();
    }
}

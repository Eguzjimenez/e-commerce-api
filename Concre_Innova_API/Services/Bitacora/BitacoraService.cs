using Concre_Innova_API.Models.DTOs.Responses;
using Concre_Innova_API.Models.Entities;
using Concre_Innova_API.Repositories.Bitacora;

namespace Concre_Innova_API.Services.Bitacora
{
    public class BitacoraService : IBitacoraService
    {
        private readonly IBitacoraRepository _repo;

        public BitacoraService(IBitacoraRepository repo)
        {
            _repo = repo;
        }

        public Task<BitacoraResult> InsertBitacoraAsync(int idUsuario, string tablaAfectada, string operacion, string descripcion, string ipUsuario)
        {
            return _repo.InsertBitacoraAsync(idUsuario, tablaAfectada, operacion, descripcion, ipUsuario);
        }

        public Task<IEnumerable<BitacoraResponseDto>> GetBitacoraAsync()
        {
            return _repo.GetBitacoraAsync();
        }
    }
}

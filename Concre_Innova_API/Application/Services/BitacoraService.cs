using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Domain.Entities;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;

namespace Concre_Innova_API.Application.Services
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

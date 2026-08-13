using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface IPreferenciasService
    {
        Task<PreferenciasUsuarioResponseDto> ObtenerAsync(int idUsuario);

        Task<OperacionResponseDto> ActualizarAsync(
            int idUsuario,
            ActualizarPreferenciasRequest request);
    }
}

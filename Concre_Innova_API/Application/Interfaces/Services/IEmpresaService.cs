using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface IEmpresaService
    {
        Task<InformacionEmpresaResponseDto?> ObtenerInformacionAsync();

        Task<OperacionResponseDto> ActualizarInformacionAsync(
            ActualizarInformacionEmpresaRequest request,
            int idUsuario);

        Task<OperacionResponseDto> RegistrarMensajeAsync(
            CrearMensajeContactoRequest request,
            int? idUsuario);

        Task<PaginatedResponseDto<MensajeContactoResponseDto>> ObtenerMensajesAsync(
            string? estado,
            PaginationQuery pagination);
    }
}

using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Models;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface IEmpresaRepository
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

        Task<ConsultaRespondida> ResponderMensajeAsync(
            int idMensaje,
            string respuesta,
            int idUsuario);
    }
}

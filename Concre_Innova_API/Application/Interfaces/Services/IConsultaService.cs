using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    /// <summary>
    /// Bandeja de consultas enviadas desde el formulario de contacto.
    /// </summary>
    public interface IConsultaService
    {
        Task<PaginatedResponseDto<MensajeContactoResponseDto>> ObtenerAsync(
            string? estado,
            PaginationQuery pagination);

        Task<OperacionResponseDto> ResponderAsync(
            int idConsulta,
            ResponderConsultaRequest request,
            int idUsuario);
    }
}

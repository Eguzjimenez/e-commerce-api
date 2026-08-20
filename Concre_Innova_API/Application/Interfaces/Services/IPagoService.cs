using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface IPagoService
    {
        Task<OperacionResponseDto> RegistrarComprobanteAsync(
            int idUsuario,
            RegistrarComprobantePagoRequest request,
            CancellationToken cancellationToken);
    }
}

using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface IPagoRepository
    {
        Task<OperacionResponseDto> RegistrarComprobanteAsync(
            int idPedido,
            int idUsuario,
            string referencia,
            string? comprobanteArchivo,
            CancellationToken cancellationToken);
    }
}

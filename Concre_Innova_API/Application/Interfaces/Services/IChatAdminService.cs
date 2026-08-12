using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    /// <summary>
    /// Consola de soporte: conversaciones escaladas y respuestas del personal.
    /// </summary>
    public interface IChatAdminService
    {
        Task<IReadOnlyList<ChatAdminResponseDto>> ObtenerConversacionesAsync(
            string? estado,
            CancellationToken cancellationToken);

        Task<IReadOnlyList<ChatMensajeResponseDto>> ObtenerMensajesAsync(
            int idChat,
            CancellationToken cancellationToken);

        Task<ChatMensajeResponseDto?> ResponderAsync(
            int idChat,
            EnviarMensajeChatRequest request,
            CancellationToken cancellationToken);
    }
}

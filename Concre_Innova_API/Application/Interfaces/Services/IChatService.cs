using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    /// <summary>
    /// Conversacion de chat vista por la persona que consulta.
    /// </summary>
    public interface IChatService
    {
        Task<ChatRespuestaBotResponseDto> EnviarMensajeAsync(
            int? idUsuario,
            EnviarMensajeChatRequest request,
            CancellationToken cancellationToken);

        Task<ChatConversacionResponseDto> ObtenerConversacionAsync(
            int idUsuario,
            CancellationToken cancellationToken);

        Task<ChatOperacionResponseDto> EscalarASoporteAsync(
            int idUsuario,
            CancellationToken cancellationToken);

        Task<ChatOperacionResponseDto> FinalizarConversacionAsync(
            int idUsuario,
            CancellationToken cancellationToken);
    }
}

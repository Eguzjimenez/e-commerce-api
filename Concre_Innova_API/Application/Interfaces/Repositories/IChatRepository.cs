using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface IChatRepository
    {
        Task<int?> ObtenerOCrearChatAsync(int idUsuario, CancellationToken cancellationToken);

        Task<ChatMensajeResponseDto?> RegistrarMensajeAsync(
            int idChat,
            string remitente,
            string mensaje,
            CancellationToken cancellationToken);

        Task<ChatConversacionResponseDto> ObtenerConversacionAsync(
            int idUsuario,
            CancellationToken cancellationToken);

        Task<ChatOperacionResponseDto> EscalarASoporteAsync(
            int idChat,
            string mensajeNotificacion,
            CancellationToken cancellationToken);

        Task<ChatOperacionResponseDto> FinalizarAsync(
            int idChat,
            CancellationToken cancellationToken);

        Task<IReadOnlyList<ChatAdminResponseDto>> ObtenerChatsAdminAsync(
            string? estado,
            CancellationToken cancellationToken);

        Task<IReadOnlyList<ChatMensajeResponseDto>> ObtenerMensajesAsync(
            int idChat,
            CancellationToken cancellationToken);

        Task<ChatAdminResumenResponseDto> ObtenerResumenAdminAsync(
            CancellationToken cancellationToken);
    }
}

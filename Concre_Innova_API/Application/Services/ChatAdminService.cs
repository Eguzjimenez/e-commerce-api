using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Interfaces.Validators;
using Concre_Innova_API.Domain.Constants;

namespace Concre_Innova_API.Application.Services
{
    public class ChatAdminService : IChatAdminService
    {
        private readonly IChatRepository _chatRepository;
        private readonly IChatRequestValidator _chatRequestValidator;

        public ChatAdminService(
            IChatRepository chatRepository,
            IChatRequestValidator chatRequestValidator)
        {
            _chatRepository = chatRepository;
            _chatRequestValidator = chatRequestValidator;
        }

        public Task<IReadOnlyList<ChatAdminResponseDto>> ObtenerConversacionesAsync(
            string? estado,
            CancellationToken cancellationToken)
        {
            return _chatRepository.ObtenerChatsAdminAsync(estado, cancellationToken);
        }

        public Task<IReadOnlyList<ChatMensajeResponseDto>> ObtenerMensajesAsync(
            int idChat,
            CancellationToken cancellationToken)
        {
            return _chatRepository.ObtenerMensajesAsync(idChat, cancellationToken);
        }

        public async Task<ChatMensajeResponseDto?> ResponderAsync(
            int idChat,
            EnviarMensajeChatRequest request,
            CancellationToken cancellationToken)
        {
            var mensajeValidacion = _chatRequestValidator.ValidateMensaje(request);
            if (mensajeValidacion is not null)
                return null;

            return await _chatRepository.RegistrarMensajeAsync(
                idChat,
                ChatRemitentes.Soporte,
                request.MensajeNormalizado,
                cancellationToken);
        }
    }
}

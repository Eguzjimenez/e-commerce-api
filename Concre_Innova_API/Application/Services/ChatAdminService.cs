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
        private readonly INotificacionEventoService _notificacionEventoService;

        public ChatAdminService(
            IChatRepository chatRepository,
            IChatRequestValidator chatRequestValidator,
            INotificacionEventoService notificacionEventoService)
        {
            _chatRepository = chatRepository;
            _chatRequestValidator = chatRequestValidator;
            _notificacionEventoService = notificacionEventoService;
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

            var mensaje = await _chatRepository.RegistrarMensajeAsync(
                idChat,
                ChatRemitentes.Soporte,
                request.MensajeNormalizado,
                cancellationToken);

            if (mensaje is not null)
            {
                await _notificacionEventoService.NotificarRespuestaDeSoporteAsync(
                    idChat,
                    request.MensajeNormalizado,
                    cancellationToken);
            }

            return mensaje;
        }

        public async Task<ChatOperacionResponseDto> CerrarConversacionAsync(
            int idChat,
            CancellationToken cancellationToken)
        {
            if (idChat <= 0)
            {
                return new ChatOperacionResponseDto
                {
                    Exitoso = false,
                    Mensaje = "La conversacion indicada no es valida."
                };
            }

            var resultado = await _chatRepository.FinalizarAsync(idChat, cancellationToken);

            if (resultado.Exitoso)
            {
                resultado.Estado = ChatEstados.Finalizado;
                resultado.Mensaje = "Conversacion cerrada y archivada en el historial.";
            }

            return resultado;
        }

        public Task<ChatAdminResumenResponseDto> ObtenerResumenAsync(
            CancellationToken cancellationToken)
        {
            return _chatRepository.ObtenerResumenAdminAsync(cancellationToken);
        }
    }
}

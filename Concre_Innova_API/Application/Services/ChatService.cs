using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Interfaces.Validators;
using Concre_Innova_API.Configuration.Settings;
using Concre_Innova_API.Domain.Constants;

namespace Concre_Innova_API.Application.Services
{
    public class ChatService : IChatService
    {
        private const string MensajeEscalamientoConfirmado =
            "Tu consulta fue enviada a nuestro equipo de soporte. " +
            "Una persona del equipo continuara la conversacion.";

        private readonly IChatRepository _chatRepository;
        private readonly IChatBotService _chatBotService;
        private readonly IChatRequestValidator _chatRequestValidator;
        private readonly SoporteHumanoSettings _soporteHumanoSettings;

        public ChatService(
            IChatRepository chatRepository,
            IChatBotService chatBotService,
            IChatRequestValidator chatRequestValidator,
            SoporteHumanoSettings soporteHumanoSettings)
        {
            _chatRepository = chatRepository;
            _chatBotService = chatBotService;
            _chatRequestValidator = chatRequestValidator;
            _soporteHumanoSettings = soporteHumanoSettings;
        }

        public async Task<ChatRespuestaBotResponseDto> EnviarMensajeAsync(
            int? idUsuario,
            EnviarMensajeChatRequest request,
            CancellationToken cancellationToken)
        {
            var mensajeValidacion = _chatRequestValidator.ValidateMensaje(request);
            if (mensajeValidacion is not null)
                return CrearRespuestaFallida(mensajeValidacion);

            var textoUsuario = request.MensajeNormalizado;
            var respuestaBot = await _chatBotService.ResolverRespuestaAsync(
                textoUsuario,
                cancellationToken);

            var respuesta = new ChatRespuestaBotResponseDto
            {
                Exitoso = true,
                Mensaje = "Mensaje enviado correctamente.",
                Estado = ChatEstados.Abierto,
                ProductosRecomendados = respuestaBot.ProductosRecomendados,
                SugiereEscalamiento = respuestaBot.SugiereEscalamiento,
                SoporteHumanoHabilitado = _soporteHumanoSettings.Habilitado
            };

            if (!idUsuario.HasValue)
            {
                respuesta.MensajeUsuario = CrearMensajeSinPersistir(
                    ChatRemitentes.Cliente,
                    textoUsuario);
                respuesta.MensajeBot = CrearMensajeSinPersistir(
                    ChatRemitentes.Bot,
                    respuestaBot.Texto);

                return respuesta;
            }

            var idChat = await _chatRepository.ObtenerOCrearChatAsync(
                idUsuario.Value,
                cancellationToken);

            if (!idChat.HasValue)
                return CrearRespuestaFallida("No fue posible abrir la conversacion.");

            respuesta.IdChat = idChat.Value;
            respuesta.MensajeUsuario = await _chatRepository.RegistrarMensajeAsync(
                idChat.Value,
                ChatRemitentes.Cliente,
                textoUsuario,
                cancellationToken);
            respuesta.MensajeBot = await _chatRepository.RegistrarMensajeAsync(
                idChat.Value,
                ChatRemitentes.Bot,
                respuestaBot.Texto,
                cancellationToken);
            respuesta.ConversacionRegistrada = respuesta.MensajeUsuario is not null;

            return respuesta;
        }

        public async Task<ChatConversacionResponseDto> ObtenerConversacionAsync(
            int idUsuario,
            CancellationToken cancellationToken)
        {
            var conversacion = await _chatRepository.ObtenerConversacionAsync(
                idUsuario,
                cancellationToken);

            conversacion.SoporteHumanoHabilitado = _soporteHumanoSettings.Habilitado;
            return conversacion;
        }

        public async Task<ChatOperacionResponseDto> EscalarASoporteAsync(
            int idUsuario,
            CancellationToken cancellationToken)
        {
            if (!_soporteHumanoSettings.Habilitado)
                return CrearOperacionFallida(ConstruirMensajeSoporteNoDisponible());

            var conversacion = await _chatRepository.ObtenerConversacionAsync(
                idUsuario,
                cancellationToken);

            if (!conversacion.IdChat.HasValue)
                return CrearOperacionFallida("No hay una conversacion activa para escalar.");

            if (EstaEscalada(conversacion))
            {
                return new ChatOperacionResponseDto
                {
                    Exitoso = true,
                    Estado = ChatEstados.Escalado,
                    Mensaje = "La conversacion ya fue enviada al equipo de soporte."
                };
            }

            var resultado = await _chatRepository.EscalarASoporteAsync(
                conversacion.IdChat.Value,
                ConstruirMensajeNotificacionSoporte(conversacion.IdChat.Value),
                cancellationToken);

            if (!resultado.Exitoso)
                return resultado;

            await _chatRepository.RegistrarMensajeAsync(
                conversacion.IdChat.Value,
                ChatRemitentes.Bot,
                MensajeEscalamientoConfirmado,
                cancellationToken);

            resultado.Estado = ChatEstados.Escalado;
            resultado.Mensaje = MensajeEscalamientoConfirmado;
            return resultado;
        }

        public async Task<ChatOperacionResponseDto> FinalizarConversacionAsync(
            int idUsuario,
            CancellationToken cancellationToken)
        {
            var conversacion = await _chatRepository.ObtenerConversacionAsync(
                idUsuario,
                cancellationToken);

            if (!conversacion.IdChat.HasValue)
                return CrearOperacionFallida("No hay una conversacion activa para finalizar.");

            var resultado = await _chatRepository.FinalizarAsync(
                conversacion.IdChat.Value,
                cancellationToken);

            if (resultado.Exitoso)
            {
                resultado.Estado = ChatEstados.Finalizado;
                resultado.Mensaje = "Conversacion finalizada. Gracias por escribirnos.";
            }

            return resultado;
        }

        private static bool EstaEscalada(ChatConversacionResponseDto conversacion)
        {
            return string.Equals(
                conversacion.Estado,
                ChatEstados.Escalado,
                StringComparison.OrdinalIgnoreCase);
        }

        private string ConstruirMensajeSoporteNoDisponible()
        {
            var contacto = _soporteHumanoSettings.ContactoAlternativo;

            return string.IsNullOrWhiteSpace(contacto)
                ? "La atención con un agente no esta habilitada en este momento."
                : $"La atención con un agente no esta habilitada en este momento. {contacto}";
        }

        private static string ConstruirMensajeNotificacionSoporte(int idChat)
        {
            return $"Nueva conversacion escalada a soporte. Chat #{idChat}.";
        }

        private static ChatMensajeResponseDto CrearMensajeSinPersistir(
            string remitente,
            string mensaje)
        {
            return new ChatMensajeResponseDto
            {
                Remitente = remitente,
                Mensaje = mensaje,
                FechaHora = DateTime.Now
            };
        }

        private static ChatRespuestaBotResponseDto CrearRespuestaFallida(string mensaje)
        {
            return new ChatRespuestaBotResponseDto
            {
                Exitoso = false,
                Mensaje = mensaje
            };
        }

        private static ChatOperacionResponseDto CrearOperacionFallida(string mensaje)
        {
            return new ChatOperacionResponseDto
            {
                Exitoso = false,
                Mensaje = mensaje
            };
        }
    }
}

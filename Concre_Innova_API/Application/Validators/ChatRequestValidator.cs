using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.Interfaces.Validators;

namespace Concre_Innova_API.Application.Validators
{
    public class ChatRequestValidator : IChatRequestValidator
    {
        private const int LongitudMaximaMensaje = 1000;

        public string? ValidateMensaje(EnviarMensajeChatRequest? request)
        {
            if (request is null || string.IsNullOrWhiteSpace(request.Mensaje))
                return "Escribe un mensaje antes de enviarlo.";

            if (request.MensajeNormalizado.Length > LongitudMaximaMensaje)
                return $"El mensaje no puede superar {LongitudMaximaMensaje} caracteres.";

            return null;
        }
    }
}

using Concre_Innova_API.Application.DTOs.Requests;

namespace Concre_Innova_API.Application.Interfaces.Validators
{
    public interface IChatRequestValidator
    {
        string? ValidateMensaje(EnviarMensajeChatRequest? request);
    }
}

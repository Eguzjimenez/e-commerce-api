using Concre_Innova_API.Application.Models;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    /// <summary>
    /// Interpreta el mensaje de un usuario y construye la respuesta del
    /// asistente virtual, incluidas las recomendaciones de productos.
    /// </summary>
    public interface IChatBotService
    {
        Task<RespuestaBot> ResolverRespuestaAsync(
            string mensajeUsuario,
            CancellationToken cancellationToken);
    }
}

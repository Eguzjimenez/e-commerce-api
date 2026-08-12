using Concre_Innova_API.Application.Models;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface IChatBotRepository
    {
        Task<IReadOnlyList<BotIntencion>> ObtenerIntencionesAsync(
            CancellationToken cancellationToken);
    }
}

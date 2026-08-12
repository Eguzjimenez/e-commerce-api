using Concre_Innova_API.Application.Models;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface IAlmacenamientoImagenEspacio
    {
        Task<string> GuardarAsync(
            int idUsuario,
            ImagenEspacioUpload imagen,
            string extension,
            CancellationToken cancellationToken);

        Task EliminarAsync(
            IEnumerable<string> rutasRelativas,
            CancellationToken cancellationToken);
    }
}

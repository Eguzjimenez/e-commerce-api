using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.Models;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface IAlmacenamientoImagenCotizacion
    {
        Task<CotizacionImagenAlmacenada> GuardarAsync(
            int idUsuario,
            CotizacionImagenUploadDto imagen,
            string extension,
            CancellationToken cancellationToken);

        Task EliminarAsync(
            IEnumerable<string> rutasRelativas,
            CancellationToken cancellationToken);
    }
}

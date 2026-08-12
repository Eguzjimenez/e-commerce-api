using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Models;

namespace Concre_Innova_API.Infrastructure.Files
{
    public class AlmacenamientoImagenEspacio : IAlmacenamientoImagenEspacio
    {
        private const string CarpetaModulo = "visualizaciones";

        private readonly AlmacenamientoImagenesEnDisco _almacenamiento;

        public AlmacenamientoImagenEspacio(IWebHostEnvironment environment)
        {
            _almacenamiento = new AlmacenamientoImagenesEnDisco(environment, CarpetaModulo);
        }

        public Task<string> GuardarAsync(
            int idUsuario,
            ImagenEspacioUpload imagen,
            string extension,
            CancellationToken cancellationToken)
        {
            return _almacenamiento.GuardarAsync(
                idUsuario,
                imagen.Contenido,
                extension,
                cancellationToken);
        }

        public Task EliminarAsync(
            IEnumerable<string> rutasRelativas,
            CancellationToken cancellationToken)
        {
            return _almacenamiento.EliminarAsync(rutasRelativas, cancellationToken);
        }
    }
}

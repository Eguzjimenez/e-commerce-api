using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Models;

namespace Concre_Innova_API.Infrastructure.Files
{
    /// <summary>
    /// Delega en el almacenamiento compartido en disco, igual que las imagenes
    /// de cotizaciones y de espacios, para no repetir el manejo de rutas.
    /// </summary>
    public class AlmacenamientoComprobantePago : IAlmacenamientoComprobantePago
    {
        private const string CarpetaModulo = "comprobantes";

        private readonly AlmacenamientoImagenesEnDisco _almacenamiento;

        public AlmacenamientoComprobantePago(IWebHostEnvironment environment)
        {
            _almacenamiento = new AlmacenamientoImagenesEnDisco(environment, CarpetaModulo);
        }

        public async Task<ComprobantePagoAlmacenado> GuardarAsync(
            int idUsuario,
            byte[] contenido,
            string extension,
            CancellationToken cancellationToken)
        {
            var rutaRelativa = await _almacenamiento.GuardarAsync(
                idUsuario,
                contenido,
                extension,
                cancellationToken);

            return new ComprobantePagoAlmacenado { RutaRelativa = rutaRelativa };
        }

        public Task EliminarAsync(string rutaRelativa, CancellationToken cancellationToken)
        {
            return _almacenamiento.EliminarAsync(new[] { rutaRelativa }, cancellationToken);
        }
    }
}

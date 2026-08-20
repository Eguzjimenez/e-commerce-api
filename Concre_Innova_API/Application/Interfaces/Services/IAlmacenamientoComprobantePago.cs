using Concre_Innova_API.Application.Models;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    /// <summary>
    /// Guarda el comprobante de pago que adjunta el cliente.
    /// </summary>
    public interface IAlmacenamientoComprobantePago
    {
        Task<ComprobantePagoAlmacenado> GuardarAsync(
            int idUsuario,
            byte[] contenido,
            string extension,
            CancellationToken cancellationToken);

        /// <summary>
        /// Descarta un comprobante ya escrito cuando el registro no prospera.
        /// </summary>
        Task EliminarAsync(string rutaRelativa, CancellationToken cancellationToken);
    }
}

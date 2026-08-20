namespace Concre_Innova_API.Application.Models
{
    /// <summary>
    /// Comprobante de pago subido por el cliente (por ejemplo, la captura de la
    /// transferencia SINPE Movil) ya guardado en disco.
    /// </summary>
    public class ComprobantePagoAlmacenado
    {
        public string RutaRelativa { get; init; } = string.Empty;
    }
}

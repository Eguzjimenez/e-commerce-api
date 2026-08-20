namespace Concre_Innova_API.Domain.Constants
{
    /// <summary>
    /// Reglas del comprobante de pago que adjunta el cliente. Reutiliza los
    /// formatos aceptados en el resto de cargas de imagen del sistema.
    /// </summary>
    public static class ComprobantePagoRules
    {
        public const long MaximoBytes = ImagenUsuarioRules.MaximoBytesPorImagen;
        public const int MaximoCaracteresReferencia = 100;
        public const int MinimoCaracteresReferencia = 4;

        /// <summary>
        /// Metodos de pago que exigen comprobante antes de dar el pago por recibido.
        /// </summary>
        public const string SinpeMovil = "SINPE Movil";

        public static bool RequiereComprobante(string? metodoPago)
        {
            return string.Equals(metodoPago?.Trim(), SinpeMovil, StringComparison.OrdinalIgnoreCase);
        }

        public static bool EsFormatoPermitido(string? extension, string? tipoContenido)
        {
            return ImagenUsuarioRules.EsFormatoPermitido(extension, tipoContenido);
        }
    }
}

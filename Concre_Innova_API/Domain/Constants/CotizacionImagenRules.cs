namespace Concre_Innova_API.Domain.Constants
{
    public static class CotizacionImagenRules
    {
        public const int MaximoImagenes = 5;
        public const long MaximoBytesPorImagen = ImagenUsuarioRules.MaximoBytesPorImagen;
        public const int MaximoCaracteresDescripcion = 1000;
        public const long MaximoBytesSolicitud =
            (MaximoImagenes * MaximoBytesPorImagen) + (512 * 1024);

        public static IReadOnlySet<string> ExtensionesPermitidas =>
            ImagenUsuarioRules.ExtensionesPermitidas;

        public static IReadOnlySet<string> TiposContenidoPermitidos =>
            ImagenUsuarioRules.TiposContenidoPermitidos;
    }
}

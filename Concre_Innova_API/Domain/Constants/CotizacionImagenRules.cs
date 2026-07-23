namespace Concre_Innova_API.Domain.Constants
{
    public static class CotizacionImagenRules
    {
        public const int MaximoImagenes = 5;
        public const long MaximoBytesPorImagen = 5 * 1024 * 1024;
        public const int MaximoCaracteresDescripcion = 1000;
        public const long MaximoBytesSolicitud =
            (MaximoImagenes * MaximoBytesPorImagen) + (512 * 1024);

        public static readonly IReadOnlySet<string> ExtensionesPermitidas =
            new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                ".jpg",
                ".jpeg",
                ".png",
                ".webp"
            };

        public static readonly IReadOnlySet<string> TiposContenidoPermitidos =
            new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                "image/jpeg",
                "image/jpg",
                "image/png",
                "image/webp"
            };
    }
}

namespace Concre_Innova_API.Domain.Constants
{
    /// <summary>
    /// Formatos de imagen aceptados en cualquier carga hecha por un usuario.
    /// Los modulos concretos reutilizan estos conjuntos para no repetir la
    /// misma validacion en varios lugares.
    /// </summary>
    public static class ImagenUsuarioRules
    {
        public const long MaximoBytesPorImagen = 5 * 1024 * 1024;

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

        public static bool EsFormatoPermitido(string? extension, string? tipoContenido)
        {
            return !string.IsNullOrWhiteSpace(extension) &&
                   ExtensionesPermitidas.Contains(extension) &&
                   !string.IsNullOrWhiteSpace(tipoContenido) &&
                   TiposContenidoPermitidos.Contains(tipoContenido);
        }
    }
}

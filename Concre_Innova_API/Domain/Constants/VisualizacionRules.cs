namespace Concre_Innova_API.Domain.Constants
{
    public static class VisualizacionRules
    {
        public const int MaximoProductosPorVisualizacion = 20;
        public const int MaximoCaracteresNombre = 120;
        public const int MaximoCaracteresColor = 80;
        public const int MaximoCaracteresMacetero = 150;
        public const int MaximoCantidadPorProducto = 100;
        public const long MaximoBytesSolicitud =
            ImagenUsuarioRules.MaximoBytesPorImagen + (512 * 1024);
    }
}

namespace Concre_Innova_API.Domain.Constants
{
    /// <summary>
    /// Clasificacion comercial de una categoria del catalogo, almacenada en
    /// la tabla CategoriaClasificacion y compartida por el detalle de pedido
    /// y el Asesor Inteligente.
    /// </summary>
    public static class ProductoClasificaciones
    {
        public const string Planta = "Planta";
        public const string Macetero = "Macetero";
        public const string Otro = "Otro";

        /// <summary>
        /// Orden de presentacion de las recomendaciones: primero las plantas
        /// y luego los maceteros que las acompanan.
        /// </summary>
        public static readonly IReadOnlyList<string> OrdenRecomendacion =
            new[] { Planta, Macetero };

        public static int ObtenerPrioridad(string clasificacion)
        {
            var posicion = OrdenRecomendacion
                .ToList()
                .FindIndex(valor =>
                    string.Equals(valor, clasificacion, StringComparison.OrdinalIgnoreCase));

            return posicion < 0 ? OrdenRecomendacion.Count : posicion;
        }
    }
}

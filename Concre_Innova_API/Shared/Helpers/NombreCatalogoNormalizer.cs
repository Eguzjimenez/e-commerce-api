using System.Text.RegularExpressions;

namespace Concre_Innova_API.Shared.Helpers
{
    /// <summary>
    /// Normaliza los nombres del catalogo antes de compararlos o guardarlos.
    /// Sin esto, "Macetas  Interior" y "Macetas Interior" se guardaban como dos
    /// categorias distintas porque el control de duplicados solo recortaba los
    /// extremos y no los espacios internos repetidos.
    /// </summary>
    public static partial class NombreCatalogoNormalizer
    {
        [GeneratedRegex(@"\s+")]
        private static partial Regex EspaciosRepetidos();

        public static string Normalizar(string? nombre)
        {
            if (string.IsNullOrWhiteSpace(nombre))
            {
                return string.Empty;
            }

            return EspaciosRepetidos().Replace(nombre.Trim(), " ");
        }
    }
}

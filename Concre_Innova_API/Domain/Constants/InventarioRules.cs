namespace Concre_Innova_API.Domain.Constants
{
    /// <summary>
    /// Reglas del inventario compartidas por el servicio y los filtros del
    /// listado, para que el API y el panel hablen de los mismos estados.
    /// </summary>
    public static class InventarioRules
    {
        public const string Disponible = "disponible";
        public const string Bajo = "bajo";
        public const string Agotado = "agotado";

        /// <summary>Tope defensivo para evitar ajustes por error de tecleo.</summary>
        public const int MaximoUnidades = 1_000_000;

        public static readonly string[] Estados = { Disponible, Bajo, Agotado };

        public static bool EsEstadoValido(string? estado)
        {
            return !string.IsNullOrWhiteSpace(estado) &&
                   Estados.Contains(estado.Trim().ToLowerInvariant());
        }
    }
}

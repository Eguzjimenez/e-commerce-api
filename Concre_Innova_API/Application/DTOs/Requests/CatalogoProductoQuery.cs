namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class CatalogoProductoQuery
    {
        private const string PriceSortField = "precio";
        private const string AscendingSort = "asc";
        private const string DescendingSort = "desc";

        public string? Busqueda { get; set; }
        public string? OrdenarPor { get; set; }
        public string? DireccionOrden { get; set; }
        public int? IdCategoria { get; set; }
        public int? IdTipo { get; set; }
        public decimal? PrecioMinimo { get; set; }
        public decimal? PrecioMaximo { get; set; }
        public string? Disponibilidad { get; set; }
        public string? Tamano { get; set; }
        public string? Material { get; set; }
        public string? Tipo { get; set; }

        public string? NormalizedSearchTerm =>
            NormalizeText(Busqueda);

        public string? NormalizedSortField =>
            string.Equals(OrdenarPor, PriceSortField, StringComparison.OrdinalIgnoreCase)
                ? PriceSortField
                : null;

        public string NormalizedSortDirection =>
            string.Equals(DireccionOrden, DescendingSort, StringComparison.OrdinalIgnoreCase)
                ? DescendingSort
                : AscendingSort;

        public bool HasCategoryFilter => IdCategoria.HasValue && IdCategoria.Value > 0;

        public bool HasTypeIdFilter => IdTipo.HasValue && IdTipo.Value > 0;

        public decimal? NormalizedMinimumPrice =>
            PrecioMinimo.HasValue && PrecioMinimo.Value >= 0 ? PrecioMinimo.Value : null;

        public decimal? NormalizedMaximumPrice =>
            PrecioMaximo.HasValue && PrecioMaximo.Value >= 0 ? PrecioMaximo.Value : null;

        public string? NormalizedAvailability =>
            NormalizeText(Disponibilidad)?.ToLowerInvariant() switch
            {
                "disponible" => "disponible",
                "agotado" => "agotado",
                _ => null
            };

        public string? NormalizedSize => NormalizeText(Tamano);

        public string? NormalizedMaterial => NormalizeText(Material);

        public string? NormalizedType => NormalizeText(Tipo);

        public bool HasCriteria =>
            NormalizedSearchTerm is not null ||
            NormalizedSortField is not null ||
            HasCategoryFilter ||
            HasTypeIdFilter ||
            NormalizedMinimumPrice.HasValue ||
            NormalizedMaximumPrice.HasValue ||
            NormalizedAvailability is not null ||
            NormalizedSize is not null ||
            NormalizedMaterial is not null ||
            NormalizedType is not null;

        private static string? NormalizeText(string? value)
        {
            return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
        }
    }
}

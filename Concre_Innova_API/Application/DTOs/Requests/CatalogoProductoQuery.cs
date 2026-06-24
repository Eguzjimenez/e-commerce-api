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

        public string? NormalizedSearchTerm =>
            string.IsNullOrWhiteSpace(Busqueda) ? null : Busqueda.Trim();

        public string? NormalizedSortField =>
            string.Equals(OrdenarPor, PriceSortField, StringComparison.OrdinalIgnoreCase)
                ? PriceSortField
                : null;

        public string NormalizedSortDirection =>
            string.Equals(DireccionOrden, DescendingSort, StringComparison.OrdinalIgnoreCase)
                ? DescendingSort
                : AscendingSort;

        public bool HasCategoryFilter => IdCategoria.HasValue && IdCategoria.Value > 0;

        public bool HasCriteria =>
            NormalizedSearchTerm is not null ||
            NormalizedSortField is not null ||
            HasCategoryFilter;
    }
}

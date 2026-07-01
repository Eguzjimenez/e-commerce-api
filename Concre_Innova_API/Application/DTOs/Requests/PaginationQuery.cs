namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class PaginationQuery
    {
        private const int DefaultPageNumber = 1;
        private const int MinimumPageSize = 1;
        private const int MaximumPageSize = 100;

        public PaginationQuery(int? pagina, int? tamanoPagina, int defaultPageSize)
        {
            IsRequested = pagina.HasValue || tamanoPagina.HasValue;
            PageNumber = Math.Max(pagina ?? DefaultPageNumber, DefaultPageNumber);
            PageSize = Math.Clamp(tamanoPagina ?? defaultPageSize, MinimumPageSize, MaximumPageSize);
        }

        public bool IsRequested { get; }

        public int PageNumber { get; }

        public int PageSize { get; }

        public int Offset => (PageNumber - 1) * PageSize;
    }
}

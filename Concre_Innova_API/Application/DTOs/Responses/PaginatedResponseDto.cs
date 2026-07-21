namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class PaginatedResponseDto<T>
    {
        public IEnumerable<T> Items { get; set; } = Array.Empty<T>();

        public int TotalItems { get; set; }

        public int PageNumber { get; set; }

        public int PageSize { get; set; }

        public int TotalPages =>
            PageSize <= 0 ? 0 : (int)Math.Ceiling((double)TotalItems / PageSize);

        public bool HasPreviousPage => PageNumber > 1;

        public bool HasNextPage => PageNumber < TotalPages;
    }
}

using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface IFavoriteService
    {
        Task<IEnumerable<CatalogoProductoResponseDto>> GetFavoritesAsync(int userId);
        Task<OperacionResponseDto> AddFavoriteAsync(int userId, int productId);
        Task<OperacionResponseDto> RemoveFavoriteAsync(int userId, int productId);
    }
}

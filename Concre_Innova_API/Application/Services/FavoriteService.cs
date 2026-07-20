using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;

namespace Concre_Innova_API.Application.Services
{
    public class FavoriteService : IFavoriteService
    {
        private readonly IFavoriteRepository _favoriteRepository;

        public FavoriteService(IFavoriteRepository favoriteRepository)
        {
            _favoriteRepository = favoriteRepository;
        }

        public Task<IEnumerable<CatalogoProductoResponseDto>> GetFavoritesAsync(int userId)
        {
            return _favoriteRepository.GetFavoritesAsync(userId);
        }

        public Task<int> GetFavoriteCountAsync(int userId)
        {
            return _favoriteRepository.GetFavoriteCountAsync(userId);
        }

        public Task<IEnumerable<int>> GetFavoriteProductIdsAsync(int userId)
        {
            return _favoriteRepository.GetFavoriteProductIdsAsync(userId);
        }

        public Task<OperacionResponseDto> AddFavoriteAsync(int userId, int productId)
        {
            return _favoriteRepository.AddFavoriteAsync(userId, productId);
        }

        public Task<OperacionResponseDto> RemoveFavoriteAsync(int userId, int productId)
        {
            return _favoriteRepository.RemoveFavoriteAsync(userId, productId);
        }
    }
}

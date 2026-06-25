using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;

namespace Concre_Innova_API.Application.Services
{
    public class CatalogoService : ICatalogoService
    {
        private const int DefaultRelatedProductsLimit = 4;
        private const int MaximumRelatedProductsLimit = 8;

        private readonly ICatalogoRepository _repo;

        public CatalogoService(ICatalogoRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<CatalogoProductoResponseDto>> ObtenerCatalogoProductosAsync()
        {
            return _repo.ObtenerCatalogoProductosAsync();
        }

        public Task<IEnumerable<CatalogoProductoResponseDto>> ObtenerCatalogoProductosAsync(CatalogoProductoQuery? query)
        {
            if (query is null || !query.HasCriteria)
            {
                return ObtenerCatalogoProductosAsync();
            }

            return _repo.BuscarCatalogoProductosAsync(query);
        }

        public Task<CatalogoProductoResponseDto?> ObtenerProductoPorIdAsync(int idProducto)
        {
            return _repo.ObtenerProductoPorIdAsync(idProducto);
        }

        public Task<IEnumerable<CatalogoProductoResponseDto>> ObtenerProductosRelacionadosAsync(
            int idProducto,
            int limite)
        {
            if (idProducto <= 0)
            {
                return Task.FromResult(Enumerable.Empty<CatalogoProductoResponseDto>());
            }

            var normalizedLimit = limite <= 0
                ? DefaultRelatedProductsLimit
                : Math.Min(limite, MaximumRelatedProductsLimit);

            return _repo.ObtenerProductosRelacionadosAsync(idProducto, normalizedLimit);
        }

        public Task<IEnumerable<CategoriaResponseDto>> ObtenerCategoriasAsync()
        {
            return _repo.ObtenerCategoriasAsync();
        }

        public Task<OperacionResponseDto> InsertarProductoAsync(CreateProductoRequest request)
        {
            return _repo.InsertarProductoAsync(request);
        }

        public Task<OperacionResponseDto> ActualizarProductoAsync(UpdateProductoRequest request)
        {
            return _repo.ActualizarProductoAsync(request);
        }

        public Task<OperacionResponseDto> EliminarProductoAsync(int idProducto)
        {
            return _repo.EliminarProductoAsync(idProducto);
        }
    }
}

using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;

namespace Concre_Innova_API.Application.Services
{
    public class CatalogoService : ICatalogoService
    {
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

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

        public Task<PaginatedResponseDto<CatalogoProductoResponseDto>> ObtenerCatalogoProductosPaginadoAsync(
            CatalogoProductoQuery? query,
            PaginationQuery pagination)
        {
            return _repo.BuscarCatalogoProductosPaginadoAsync(query ?? new CatalogoProductoQuery(), pagination);
        }

        public Task<CatalogoFiltrosResponseDto> ObtenerFiltrosCatalogoAsync()
        {
            return _repo.ObtenerFiltrosCatalogoAsync();
        }

        public Task<CatalogoProductoResponseDto?> ObtenerProductoPorIdAsync(int idProducto)
        {
            return _repo.ObtenerProductoPorIdAsync(idProducto);
        }

        public Task<IEnumerable<ProductoVarianteResponseDto>> ObtenerProductoVariantesAsync(int idProducto)
        {
            if (idProducto <= 0)
            {
                return Task.FromResult(Enumerable.Empty<ProductoVarianteResponseDto>());
            }

            return _repo.ObtenerProductoVariantesAsync(idProducto);
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

        public Task<IEnumerable<CategoriaResponseDto>> ObtenerCategoriasAdministracionAsync()
        {
            return _repo.ObtenerCategoriasAdministracionAsync();
        }

        public Task<CategoriaOperacionResponseDto> InsertarCategoriaAsync(CreateCategoriaRequest request)
        {
            return _repo.InsertarCategoriaAsync(request);
        }

        public Task<CategoriaOperacionResponseDto> ActualizarCategoriaAsync(UpdateCategoriaRequest request)
        {
            return _repo.ActualizarCategoriaAsync(request);
        }

        public Task<CategoriaOperacionResponseDto> EliminarCategoriaAsync(int idCategoria)
        {
            return _repo.EliminarCategoriaAsync(idCategoria);
        }

        public Task<IEnumerable<TipoProductoResponseDto>> ObtenerTiposProductoAsync()
        {
            return _repo.ObtenerTiposProductoAsync();
        }

        public Task<IEnumerable<TipoProductoResponseDto>> ObtenerTiposProductoAdministracionAsync()
        {
            return _repo.ObtenerTiposProductoAdministracionAsync();
        }

        public Task<TipoProductoOperacionResponseDto> InsertarTipoProductoAsync(CreateTipoProductoRequest request)
        {
            return _repo.InsertarTipoProductoAsync(request);
        }

        public Task<TipoProductoOperacionResponseDto> ActualizarTipoProductoAsync(UpdateTipoProductoRequest request)
        {
            return _repo.ActualizarTipoProductoAsync(request);
        }

        public Task<TipoProductoOperacionResponseDto> EliminarTipoProductoAsync(int idTipo)
        {
            return _repo.EliminarTipoProductoAsync(idTipo);
        }

        public async Task<OperacionResponseDto> InsertarProductoAsync(CreateProductoRequest request)
        {
            if (request.IdTipo.HasValue)
            {
                var esCombinacionValida = await _repo.EsCombinacionTipoCategoriaValidaAsync(
                    request.IdCategoria,
                    request.IdTipo.Value);

                if (!esCombinacionValida)
                {
                    return new OperacionResponseDto
                    {
                        Codigo = 0,
                        Mensaje = "La combinacion de categoria y tipo de producto seleccionada no es valida."
                    };
                }
            }

            return await _repo.InsertarProductoAsync(request);
        }

        public async Task<OperacionResponseDto> ActualizarProductoAsync(UpdateProductoRequest request)
        {
            if (request.IdTipo.HasValue)
            {
                var esCombinacionValida = await _repo.EsCombinacionTipoCategoriaValidaAsync(
                    request.IdCategoria,
                    request.IdTipo.Value);

                if (!esCombinacionValida)
                {
                    return new OperacionResponseDto
                    {
                        Codigo = 0,
                        Mensaje = "La combinacion de categoria y tipo de producto seleccionada no es valida."
                    };
                }
            }

            return await _repo.ActualizarProductoAsync(request);
        }

        public Task<OperacionResponseDto> EliminarProductoAsync(int idProducto)
        {
            return _repo.EliminarProductoAsync(idProducto);
        }
    }
}

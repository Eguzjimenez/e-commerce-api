using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface ICatalogoRepository
    {
        Task<IEnumerable<CatalogoProductoResponseDto>> ObtenerCatalogoProductosAsync();
        Task<IEnumerable<CatalogoProductoResponseDto>> BuscarCatalogoProductosAsync(CatalogoProductoQuery query);
        Task<CatalogoProductoResponseDto?> ObtenerProductoPorIdAsync(int idProducto);
        Task<IEnumerable<CatalogoProductoResponseDto>> ObtenerProductosRelacionadosAsync(int idProducto, int limite);
        Task<IEnumerable<CategoriaResponseDto>> ObtenerCategoriasAsync();
        Task<IEnumerable<CategoriaResponseDto>> ObtenerCategoriasAdministracionAsync();
        Task<CategoriaOperacionResponseDto> InsertarCategoriaAsync(CreateCategoriaRequest request);
        Task<CategoriaOperacionResponseDto> ActualizarCategoriaAsync(UpdateCategoriaRequest request);
        Task<CategoriaOperacionResponseDto> EliminarCategoriaAsync(int idCategoria);
        Task<IEnumerable<TipoProductoResponseDto>> ObtenerTiposProductoAsync();
        Task<IEnumerable<TipoProductoResponseDto>> ObtenerTiposProductoAdministracionAsync();
        Task<TipoProductoOperacionResponseDto> InsertarTipoProductoAsync(CreateTipoProductoRequest request);
        Task<TipoProductoOperacionResponseDto> ActualizarTipoProductoAsync(UpdateTipoProductoRequest request);
        Task<TipoProductoOperacionResponseDto> EliminarTipoProductoAsync(int idTipo);
        Task<bool> EsCombinacionTipoCategoriaValidaAsync(int idCategoria, int idTipo);
        Task<OperacionResponseDto> InsertarProductoAsync(CreateProductoRequest request);
        Task<OperacionResponseDto> ActualizarProductoAsync(UpdateProductoRequest request);
        Task<OperacionResponseDto> EliminarProductoAsync(int idProducto);
    }
}

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
        Task<OperacionResponseDto> InsertarProductoAsync(CreateProductoRequest request);
        Task<OperacionResponseDto> ActualizarProductoAsync(UpdateProductoRequest request);
        Task<OperacionResponseDto> EliminarProductoAsync(int idProducto);
    }
}

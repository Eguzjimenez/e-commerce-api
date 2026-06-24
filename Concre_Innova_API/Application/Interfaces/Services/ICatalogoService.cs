using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface ICatalogoService
    {
        Task<IEnumerable<CatalogoProductoResponseDto>> ObtenerCatalogoProductosAsync();
        Task<IEnumerable<CatalogoProductoResponseDto>> ObtenerCatalogoProductosAsync(CatalogoProductoQuery? query);
        Task<CatalogoProductoResponseDto?> ObtenerProductoPorIdAsync(int idProducto);
        Task<IEnumerable<CategoriaResponseDto>> ObtenerCategoriasAsync();
        Task<OperacionResponseDto> InsertarProductoAsync(CreateProductoRequest request);
        Task<OperacionResponseDto> ActualizarProductoAsync(UpdateProductoRequest request);
        Task<OperacionResponseDto> EliminarProductoAsync(int idProducto);
    }
}

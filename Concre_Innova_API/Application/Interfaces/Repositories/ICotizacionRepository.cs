using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.Models;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface ICotizacionRepository
    {
        Task<CrearCotizacionResponseDto> CrearAsync(
            int idUsuario,
            string descripcion,
            string preferencias,
            IReadOnlyCollection<SolicitudCotizacionProductoRequestDto> productos,
            IReadOnlyCollection<CotizacionImagenAlmacenada> imagenes,
            CancellationToken cancellationToken);

        Task<PaginatedResponseDto<CotizacionHistorialResponseDto>> ObtenerPorUsuarioAsync(
            int idUsuario,
            CotizacionHistorialQuery query,
            PaginationQuery pagination,
            CancellationToken cancellationToken);

        Task<PaginatedResponseDto<CotizacionHistorialResponseDto>> ObtenerAdminAsync(
            CotizacionHistorialQuery query,
            PaginationQuery pagination,
            CancellationToken cancellationToken);

        Task<ActualizarCotizacionResponseDto> ResponderAsync(
            int idCotizacion,
            string respuesta,
            IReadOnlyCollection<CotizacionProductoRequestDto> productos,
            CancellationToken cancellationToken);

        Task<ActualizarCotizacionResponseDto> DecidirAsync(
            int idUsuario,
            int idCotizacion,
            bool aceptar,
            CancellationToken cancellationToken);

        Task<ActualizarCotizacionResponseDto> ResolverPorVendedorAsync(
            int idCotizacion,
            bool aprobar,
            CancellationToken cancellationToken);

        Task<ActualizarCotizacionResponseDto> ConvertirEnPedidoAsync(
            int idCotizacion,
            CancellationToken cancellationToken);
    }
}

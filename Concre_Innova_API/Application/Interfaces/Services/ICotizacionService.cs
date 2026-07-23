using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface ICotizacionService
    {
        Task<CrearCotizacionResponseDto> CrearAsync(
            int idUsuario,
            CrearCotizacionRequestDto request,
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
            ResponderCotizacionRequestDto request,
            CancellationToken cancellationToken);

        Task<ActualizarCotizacionResponseDto> DecidirAsync(
            int idUsuario,
            int idCotizacion,
            DecidirCotizacionRequestDto request,
            CancellationToken cancellationToken);

        Task<ActualizarCotizacionResponseDto> ResolverPorVendedorAsync(
            int idCotizacion,
            ResolverCotizacionVendedorRequestDto request,
            CancellationToken cancellationToken);

        Task<ActualizarCotizacionResponseDto> ConvertirEnPedidoAsync(
            int idCotizacion,
            CancellationToken cancellationToken);
    }
}

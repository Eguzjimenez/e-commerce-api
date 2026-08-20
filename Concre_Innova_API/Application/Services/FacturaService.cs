using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Domain.Constants;

namespace Concre_Innova_API.Application.Services
{
    public class FacturaService : IFacturaService
    {
        private readonly IFacturaRepository _facturaRepository;

        public FacturaService(IFacturaRepository facturaRepository)
        {
            _facturaRepository = facturaRepository;
        }

        public Task<FacturaListadoResponseDto> BuscarAsync(
            FacturaQuery query,
            PaginationQuery pagination,
            CancellationToken cancellationToken)
        {
            // Un filtro desconocido se descarta: mejor el listado completo que
            // una lista vacia sin explicacion.
            if (!FacturaRules.EsFiltroValido(query.Estado))
            {
                query.Estado = null;
            }
            else
            {
                query.Estado = query.Estado!.Trim().ToLowerInvariant();
            }

            return _facturaRepository.BuscarAsync(query, pagination, cancellationToken);
        }

        public Task<FacturaDetalleResponseDto?> ObtenerDetalleAsync(
            int idVenta,
            CancellationToken cancellationToken)
        {
            return _facturaRepository.ObtenerDetalleAsync(idVenta, cancellationToken);
        }

        public async Task<OperacionResponseDto> ActualizarEstadoAsync(
            ActualizarEstadoFacturaRequest request,
            int idUsuario,
            CancellationToken cancellationToken)
        {
            var mensaje = Validar(request);

            if (mensaje is not null)
            {
                return new OperacionResponseDto { Codigo = 0, Mensaje = mensaje };
            }

            var resultado = await _facturaRepository.ActualizarEstadoAsync(
                request, idUsuario, cancellationToken);

            resultado.Mensaje = Traducir(resultado.Mensaje);
            return resultado;
        }

        private static string? Validar(ActualizarEstadoFacturaRequest request)
        {
            if (request.IdVenta <= 0)
                return "La factura indicada no es valida.";

            if (!FacturaRules.EsEstadoPagoValido(request.EstadoPago))
                return "El estado de cobro indicado no es valido.";

            if ((request.Observaciones?.Trim().Length ?? 0) >
                FacturaRules.MaximoCaracteresObservaciones)
            {
                return $"Las observaciones no pueden superar {FacturaRules.MaximoCaracteresObservaciones} caracteres.";
            }

            return null;
        }

        private static string Traducir(string? codigo) => codigo switch
        {
            "FACTURA_ACTUALIZADA" => "El estado de la factura se actualizo correctamente.",
            "FACTURA_NO_ENCONTRADA" => "La factura indicada no existe.",
            "ESTADO_INVALIDO" => "El estado de cobro indicado no es valido.",
            _ => "No fue posible actualizar la factura."
        };
    }
}

using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Domain.Constants;

namespace Concre_Innova_API.Application.Services
{
    public class InventarioService : IInventarioService
    {
        private readonly IInventarioRepository _inventarioRepository;

        public InventarioService(IInventarioRepository inventarioRepository)
        {
            _inventarioRepository = inventarioRepository;
        }

        public Task<PaginatedResponseDto<InventarioItemResponseDto>> BuscarAsync(
            InventarioQuery query,
            PaginationQuery pagination,
            CancellationToken cancellationToken)
        {
            // Un estado desconocido se descarta en vez de devolver una lista vacia
            // sin explicacion: el listado completo es la respuesta util.
            if (!InventarioRules.EsEstadoValido(query.Estado))
            {
                query.Estado = null;
            }

            return _inventarioRepository.BuscarAsync(query, pagination, cancellationToken);
        }

        public Task<InventarioDetalleResponseDto?> ObtenerDetalleAsync(
            int idProducto,
            CancellationToken cancellationToken)
        {
            return _inventarioRepository.ObtenerDetalleAsync(idProducto, cancellationToken);
        }

        public async Task<OperacionResponseDto> ActualizarAsync(
            ActualizarInventarioRequest request,
            int idUsuario,
            CancellationToken cancellationToken)
        {
            var mensaje = Validar(request);

            if (mensaje is not null)
            {
                return new OperacionResponseDto
                {
                    Codigo = 0,
                    Mensaje = mensaje,
                    IdProducto = request.IdProducto
                };
            }

            var resultado = await _inventarioRepository.ActualizarAsync(
                request,
                idUsuario,
                cancellationToken);

            resultado.Mensaje = Traducir(resultado.Mensaje);
            return resultado;
        }

        private static string? Validar(ActualizarInventarioRequest request)
        {
            if (request.IdProducto <= 0)
            {
                return "El producto indicado no es valido.";
            }

            if (request.CantidadDisponible < 0 || request.CantidadMinima < 0)
            {
                return "Las cantidades no pueden ser negativas.";
            }

            if (request.CantidadDisponible > InventarioRules.MaximoUnidades ||
                request.CantidadMinima > InventarioRules.MaximoUnidades)
            {
                return $"Las cantidades no pueden superar {InventarioRules.MaximoUnidades} unidades.";
            }

            return null;
        }

        private static string Traducir(string? codigo) => codigo switch
        {
            "INVENTARIO_ACTUALIZADO" => "Las existencias se actualizaron correctamente.",
            "PRODUCTO_NO_ENCONTRADO" => "El producto indicado no existe.",
            "CANTIDAD_INVALIDA" => "Las cantidades no pueden ser negativas.",
            _ => "No fue posible actualizar las existencias."
        };
    }
}

using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;

namespace Concre_Innova_API.Application.Services
{
    public class CarritoService : ICarritoService
    {
        private const int LongitudMaximaDireccion = 255;
        private const int LongitudMaximaMetodoPago = 50;
        private const int LongitudMaximaNombreVariante = 120;
        private const int LongitudMaximaAtributo = 80;

        private static readonly Dictionary<string, string> MetodosPagoPermitidos =
            new(StringComparer.OrdinalIgnoreCase)
            {
                ["Tarjeta"] = "Tarjeta",
                ["SINPE Movil"] = "SINPE Movil",
                ["Efectivo contra entrega"] = "Efectivo contra entrega"
            };

        private readonly ICarritoRepository _carritoRepository;
        private readonly INotificacionEventoService _notificacionEventoService;

        public CarritoService(
            ICarritoRepository carritoRepository,
            INotificacionEventoService notificacionEventoService)
        {
            _carritoRepository = carritoRepository;
            _notificacionEventoService = notificacionEventoService;
        }

        public async Task<ValidarStockCarritoResponseDto> ValidarStockCarritoAsync(
            ValidarStockCarritoRequest request)
        {
            if (request == null || request.Items == null || !request.Items.Any())
            {
                return new ValidarStockCarritoResponseDto();
            }

            return await _carritoRepository.ValidarStockCarritoAsync(request.Items);
        }

        public async Task<RegistrarPedidoResponseDto> RegistrarPedidoAsync(
            RegistrarPedidoRequest request)
        {
            if (request == null || request.Items == null || !request.Items.Any())
            {
                return CrearError("El carrito está vacío o la solicitud es inválida.");
            }

            if (request.IdUsuario <= 0)
            {
                return CrearError("El ID de usuario no es válido.");
            }

            var direccionEntrega = request.DireccionEntrega?.Trim() ?? string.Empty;
            if (string.IsNullOrWhiteSpace(direccionEntrega))
            {
                return CrearError("La dirección de entrega es requerida.");
            }

            if (direccionEntrega.Length > LongitudMaximaDireccion)
            {
                return CrearError(
                    $"La dirección de entrega no puede superar {LongitudMaximaDireccion} caracteres.");
            }

            var metodoPago = request.MetodoPago?.Trim() ?? string.Empty;
            if (string.IsNullOrWhiteSpace(metodoPago))
            {
                return CrearError("El método de pago es requerido.");
            }

            if (metodoPago.Length > LongitudMaximaMetodoPago ||
                !MetodosPagoPermitidos.TryGetValue(metodoPago, out var metodoPagoNormalizado))
            {
                return CrearError("El método de pago seleccionado no es válido.");
            }

            if (request.Items.Any(EsItemPedidoInvalido))
            {
                return CrearError(
                    "Uno o más productos del carrito contienen valores inválidos.");
            }

            request.DireccionEntrega = direccionEntrega;
            request.MetodoPago = metodoPagoNormalizado;

            var resultado = await _carritoRepository.RegistrarPedidoAsync(request);

            if (resultado.Exitoso && resultado.IdPedido.HasValue)
            {
                await _notificacionEventoService.NotificarPedidoRegistradoAsync(
                    resultado.IdPedido.Value,
                    resultado.Total ?? decimal.Zero,
                    CancellationToken.None);
            }

            return resultado;
        }

        public async Task<MisPedidosResponseDto> ObtenerMisPedidosAsync(
            int idUsuario,
            DateTime? fechaDesde,
            DateTime? fechaHasta)
        {
            if (idUsuario <= 0)
            {
                return new MisPedidosResponseDto
                {
                    Exitoso = false,
                    Mensaje = "El ID de usuario no es válido."
                };
            }

            var fechaInicial = fechaDesde?.Date;
            var fechaFinal = fechaHasta?.Date;

            if (fechaInicial.HasValue &&
                fechaFinal.HasValue &&
                fechaInicial > fechaFinal)
            {
                return new MisPedidosResponseDto
                {
                    Exitoso = false,
                    Mensaje = "La fecha inicial no puede ser posterior a la fecha final."
                };
            }

            return await _carritoRepository.ObtenerMisPedidosAsync(
                idUsuario,
                fechaInicial,
                fechaFinal);
        }

        public async Task<RecompraPedidoResponseDto> PrepararRecompraPedidoAsync(
            int idUsuario,
            int idPedido)
        {
            if (idUsuario <= 0 || idPedido <= 0)
            {
                return new RecompraPedidoResponseDto
                {
                    Exitoso = false,
                    Mensaje = "El usuario o el pedido no son válidos."
                };
            }

            return await _carritoRepository.PrepararRecompraPedidoAsync(
                idUsuario,
                idPedido);
        }

        private static RegistrarPedidoResponseDto CrearError(string mensaje)
        {
            return new RegistrarPedidoResponseDto
            {
                Exitoso = false,
                Mensaje = mensaje
            };
        }

        private static bool EsItemPedidoInvalido(ItemCarritoRequest item)
        {
            return item.IdProducto <= 0 ||
                   item.Cantidad <= 0 ||
                   ExcedeLongitud(item.NombreVariante, LongitudMaximaNombreVariante) ||
                   ExcedeLongitud(item.Tamano, LongitudMaximaAtributo) ||
                   ExcedeLongitud(item.Material, LongitudMaximaAtributo) ||
                   ExcedeLongitud(item.Color, LongitudMaximaAtributo);
        }

        private static bool ExcedeLongitud(string? valor, int longitudMaxima)
        {
            return valor?.Trim().Length > longitudMaxima;
        }
    }
}

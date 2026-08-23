using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Services;
using Xunit;

namespace Concre_Innova_API.Tests;

/// <summary>
/// Los procedimientos almacenados responden con codigos internos y, ante un
/// fallo inesperado, con el texto del motor. Ninguno de los dos debe llegar a
/// la persona usuaria.
/// </summary>
public class MensajesDePedidoTests
{
    private sealed class CarritoRepositorioFalso : ICarritoRepository
    {
        private readonly RegistrarPedidoResponseDto _respuesta;

        public CarritoRepositorioFalso(RegistrarPedidoResponseDto respuesta)
        {
            _respuesta = respuesta;
        }

        public Task<RegistrarPedidoResponseDto> RegistrarPedidoAsync(RegistrarPedidoRequest request)
            => Task.FromResult(_respuesta);

        public Task<ValidarStockCarritoResponseDto> ValidarStockCarritoAsync(List<ItemCarritoRequest> items)
            => Task.FromResult(new ValidarStockCarritoResponseDto());

        public Task<MisPedidosResponseDto> ObtenerMisPedidosAsync(
            int idUsuario,
            DateTime? fechaDesde,
            DateTime? fechaHasta)
            => Task.FromResult(new MisPedidosResponseDto());

        public Task<RecompraPedidoResponseDto> PrepararRecompraPedidoAsync(int idUsuario, int idPedido)
            => Task.FromResult(new RecompraPedidoResponseDto());
    }

    private sealed class NotificacionEventoSilenciosa : INotificacionEventoService
    {
        public Task NotificarPedidoRegistradoAsync(int idPedido, decimal total, CancellationToken cancellationToken)
            => Task.CompletedTask;

        public Task NotificarEstadoPedidoAsync(int idPedido, string estado, CancellationToken cancellationToken)
            => Task.CompletedTask;

        public Task NotificarCotizacionActualizadaAsync(int idCotizacion, string estado, CancellationToken cancellationToken)
            => Task.CompletedTask;

        public Task NotificarRespuestaDeSoporteAsync(int idChat, string mensaje, CancellationToken cancellationToken)
            => Task.CompletedTask;
    }

    private static RegistrarPedidoRequest SolicitudValida() => new()
    {
        IdUsuario = 7,
        DireccionEntrega = "San Miguel Oeste, Naranjo",
        MetodoPago = "SINPE Movil",
        Items = new List<ItemCarritoRequest>
        {
            new() { IdProducto = 1, Cantidad = 2 }
        }
    };

    private static async Task<string?> MensajeDevueltoAsync(RegistrarPedidoResponseDto respuestaSql)
    {
        var servicio = new CarritoService(
            new CarritoRepositorioFalso(respuestaSql),
            new NotificacionEventoSilenciosa());

        var resultado = await servicio.RegistrarPedidoAsync(SolicitudValida());
        return resultado.Mensaje;
    }

    [Fact]
    public async Task Traduce_el_codigo_de_pedido_registrado()
    {
        var mensaje = await MensajeDevueltoAsync(new RegistrarPedidoResponseDto
        {
            Exitoso = true,
            Mensaje = "PEDIDO_REGISTRADO",
            IdPedido = 15,
            IdCliente = 3,
            Total = 43000m
        });

        Assert.Equal("Tu pedido fue registrado correctamente.", mensaje);
    }

    [Fact]
    public async Task Traduce_el_codigo_de_stock_insuficiente()
    {
        var mensaje = await MensajeDevueltoAsync(new RegistrarPedidoResponseDto
        {
            Exitoso = false,
            Mensaje = "STOCK_INSUFICIENTE"
        });

        Assert.Contains("existencias", mensaje);
        Assert.DoesNotContain("STOCK_INSUFICIENTE", mensaje);
    }

    [Fact]
    public async Task No_expone_el_texto_del_motor_ante_un_error_inesperado()
    {
        var mensaje = await MensajeDevueltoAsync(new RegistrarPedidoResponseDto
        {
            Exitoso = false,
            Mensaje = "Violation of PRIMARY KEY constraint 'PK_Pedidos' in dbo.Pedidos."
        });

        Assert.Equal("No fue posible registrar el pedido. Inténtalo nuevamente.", mensaje);
    }
}

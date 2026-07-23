using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;

namespace Concre_Innova_API.Application.Services
{
    public class CarritoService : ICarritoService
    {
        private readonly ICarritoRepository _carritoRepository;

        public CarritoService(ICarritoRepository carritoRepository)
        {
            _carritoRepository = carritoRepository;
        }

        public async Task<ValidarStockCarritoResponseDto> ValidarStockCarritoAsync(ValidarStockCarritoRequest request)
        {
            if (request == null || request.Items == null || !request.Items.Any())
            {
                return new ValidarStockCarritoResponseDto();
            }

            return await _carritoRepository.ValidarStockCarritoAsync(request.Items);
        }

        public async Task<RegistrarPedidoResponseDto> RegistrarPedidoAsync(RegistrarPedidoRequest request)
        {
            if (request == null || request.Items == null || !request.Items.Any())
            {
                return new RegistrarPedidoResponseDto
                {
                    Exitoso = false,
                    Mensaje = "El carrito está vacío o la solicitud es inválida."
                };
            }

            if (string.IsNullOrWhiteSpace(request.DireccionEntrega))
            {
                return new RegistrarPedidoResponseDto
                {
                    Exitoso = false,
                    Mensaje = "La dirección de entrega es requerida."
                };
            }

            if (string.IsNullOrWhiteSpace(request.MetodoPago))
            {
                return new RegistrarPedidoResponseDto
                {
                    Exitoso = false,
                    Mensaje = "El método de pago es requerido."
                };
            }

            return await _carritoRepository.RegistrarPedidoAsync(request);
        }

        public async Task<MisPedidosResponseDto> ObtenerMisPedidosAsync(int idUsuario)
        {
            if (idUsuario <= 0)
            {
                return new MisPedidosResponseDto
                {
                    Exitoso = false,
                    Mensaje = "El ID de usuario no es válido."
                };
            }

            return await _carritoRepository.ObtenerMisPedidosAsync(idUsuario);
        }
    }
}

using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Domain.Constants;

namespace Concre_Innova_API.Application.Services
{
    public class PagoService : IPagoService
    {
        private readonly IPagoRepository _pagoRepository;
        private readonly IAlmacenamientoComprobantePago _almacenamiento;

        public PagoService(
            IPagoRepository pagoRepository,
            IAlmacenamientoComprobantePago almacenamiento)
        {
            _pagoRepository = pagoRepository;
            _almacenamiento = almacenamiento;
        }

        public async Task<OperacionResponseDto> RegistrarComprobanteAsync(
            int idUsuario,
            RegistrarComprobantePagoRequest request,
            CancellationToken cancellationToken)
        {
            var validacion = Validar(request);
            if (validacion is not null)
            {
                return validacion;
            }

            var rutaComprobante = await GuardarAdjuntoAsync(idUsuario, request, cancellationToken);

            var resultado = await _pagoRepository.RegistrarComprobanteAsync(
                request.IdPedido,
                idUsuario,
                request.Referencia!.Trim(),
                rutaComprobante,
                cancellationToken);

            // El procedimiento almacenado es quien valida la propiedad del pedido:
            // si rechaza el registro, el archivo escrito no debe quedar huerfano.
            if (resultado.Codigo != 1 && rutaComprobante is not null)
            {
                await _almacenamiento.EliminarAsync(rutaComprobante, cancellationToken);
            }

            resultado.Mensaje = TraducirResultado(resultado.Mensaje);

            return resultado;
        }

        /// <summary>
        /// Convierte los codigos del procedimiento almacenado en mensajes que el
        /// cliente pueda entender, sin exponer detalle interno de la base.
        /// </summary>
        private static string TraducirResultado(string? codigo) => codigo switch
        {
            "COMPROBANTE_REGISTRADO" => "El comprobante quedo registrado y esta en verificacion.",
            "COMPROBANTE_REQUERIDO" =>
                "SINPE Movil requiere adjuntar el comprobante de la transferencia.",
            "VENTA_NO_ENCONTRADA" => "No se encontró un pago pendiente para ese pedido.",
            _ => "No fue posible registrar el comprobante del pago."
        };

        /// <summary>
        /// Guarda el adjunto cuando el cliente lo envia. Los metodos que exigen
        /// comprobante se validan en el procedimiento almacenado, que es quien
        /// conoce el metodo de pago real de la venta.
        /// </summary>
        private async Task<string?> GuardarAdjuntoAsync(
            int idUsuario,
            RegistrarComprobantePagoRequest request,
            CancellationToken cancellationToken)
        {
            if (request.Comprobante is null || request.Comprobante.Length == 0)
            {
                return null;
            }

            var extension = Path.GetExtension(request.Comprobante.FileName).ToLowerInvariant();

            await using var lectura = request.Comprobante.OpenReadStream();
            using var memoria = new MemoryStream();
            await lectura.CopyToAsync(memoria, cancellationToken);

            var archivo = await _almacenamiento.GuardarAsync(
                idUsuario,
                memoria.ToArray(),
                extension,
                cancellationToken);

            return archivo.RutaRelativa;
        }

        private static OperacionResponseDto? Validar(RegistrarComprobantePagoRequest request)
        {
            if (request.IdPedido <= 0)
            {
                return CrearError("El pedido indicado no es válido.");
            }

            var referencia = request.Referencia?.Trim() ?? string.Empty;

            if (referencia.Length < ComprobantePagoRules.MinimoCaracteresReferencia ||
                referencia.Length > ComprobantePagoRules.MaximoCaracteresReferencia)
            {
                return CrearError(
                    "El número de referencia del comprobante no es válido.");
            }

            if (request.Comprobante is null || request.Comprobante.Length == 0)
            {
                return null;
            }

            if (request.Comprobante.Length > ComprobantePagoRules.MaximoBytes)
            {
                return CrearError("El comprobante supera el tamaño máximo permitido.");
            }

            var extension = Path.GetExtension(request.Comprobante.FileName).ToLowerInvariant();

            if (!ComprobantePagoRules.EsFormatoPermitido(extension, request.Comprobante.ContentType))
            {
                return CrearError("El formato del comprobante no esta permitido.");
            }

            return null;
        }

        private static OperacionResponseDto CrearError(string mensaje)
        {
            return new OperacionResponseDto { Codigo = 0, Mensaje = mensaje };
        }
    }
}

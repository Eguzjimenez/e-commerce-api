using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Shared.Helpers;

namespace Concre_Innova_API.Application.Services
{
    public class EmpresaService : IEmpresaService
    {
        private const int LongitudMaximaNombre = 150;
        private const int LongitudMaximaAsunto = 150;
        private const int LongitudMaximaMensaje = 2000;

        private readonly IEmpresaRepository _empresaRepository;

        public EmpresaService(IEmpresaRepository empresaRepository)
        {
            _empresaRepository = empresaRepository;
        }

        public async Task<InformacionEmpresaResponseDto?> ObtenerInformacionAsync()
        {
            return await _empresaRepository.ObtenerInformacionAsync();
        }

        public async Task<OperacionResponseDto> ActualizarInformacionAsync(
            ActualizarInformacionEmpresaRequest request,
            int idUsuario)
        {
            if (request is null)
            {
                return CrearError("La solicitud no es válida.");
            }

            if (string.IsNullOrWhiteSpace(request.NombreEmpresa))
            {
                return CrearError("El nombre de la empresa es requerido.");
            }

            if (!string.IsNullOrWhiteSpace(request.Correo) && !EsCorreoValido(request.Correo))
            {
                return CrearError("El correo de contacto no es válido.");
            }

            return await _empresaRepository.ActualizarInformacionAsync(request, idUsuario);
        }

        public async Task<OperacionResponseDto> RegistrarMensajeAsync(
            CrearMensajeContactoRequest request,
            int? idUsuario)
        {
            if (request is null)
            {
                return CrearError("La solicitud no es válida.");
            }

            var nombre = request.Nombre?.Trim() ?? string.Empty;
            var correo = request.Correo?.Trim() ?? string.Empty;
            var asunto = request.Asunto?.Trim() ?? string.Empty;
            var mensaje = request.Mensaje?.Trim() ?? string.Empty;

            if (string.IsNullOrWhiteSpace(nombre) || nombre.Length > LongitudMaximaNombre)
            {
                return CrearError("El nombre es requerido y no puede superar 150 caracteres.");
            }

            if (!EsCorreoValido(correo))
            {
                return CrearError("El correo electrónico no es válido.");
            }

            if (string.IsNullOrWhiteSpace(asunto) || asunto.Length > LongitudMaximaAsunto)
            {
                return CrearError("El asunto es requerido y no puede superar 150 caracteres.");
            }

            if (string.IsNullOrWhiteSpace(mensaje) || mensaje.Length > LongitudMaximaMensaje)
            {
                return CrearError("El mensaje es requerido y no puede superar 2000 caracteres.");
            }

            // El telefono es opcional, pero si se envia debe ser utilizable para responder.
            if (!PhoneNumberValidator.IsValidOrEmpty(request.Telefono))
            {
                return CrearError("El teléfono debe contener entre 8 y 15 digitos.");
            }

            return await _empresaRepository.RegistrarMensajeAsync(request, idUsuario);
        }

        public async Task<PaginatedResponseDto<MensajeContactoResponseDto>> ObtenerMensajesAsync(
            string? estado,
            PaginationQuery pagination)
        {
            return await _empresaRepository.ObtenerMensajesAsync(estado, pagination);
        }

        // Se reutiliza el validador compartido para no mantener dos reglas de correo.
        private static bool EsCorreoValido(string? correo)
        {
            return EmailAddressValidator.IsValid(correo);
        }

        private static OperacionResponseDto CrearError(string mensaje)
        {
            return new OperacionResponseDto
            {
                Codigo = 0,
                Mensaje = mensaje
            };
        }
    }
}

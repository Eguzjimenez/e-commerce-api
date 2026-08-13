using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;

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
                return CrearError("La solicitud no es valida.");
            }

            if (string.IsNullOrWhiteSpace(request.NombreEmpresa))
            {
                return CrearError("El nombre de la empresa es requerido.");
            }

            if (!string.IsNullOrWhiteSpace(request.Correo) && !EsCorreoValido(request.Correo))
            {
                return CrearError("El correo de contacto no es valido.");
            }

            return await _empresaRepository.ActualizarInformacionAsync(request, idUsuario);
        }

        public async Task<OperacionResponseDto> RegistrarMensajeAsync(
            CrearMensajeContactoRequest request,
            int? idUsuario)
        {
            if (request is null)
            {
                return CrearError("La solicitud no es valida.");
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
                return CrearError("El correo electronico no es valido.");
            }

            if (string.IsNullOrWhiteSpace(asunto) || asunto.Length > LongitudMaximaAsunto)
            {
                return CrearError("El asunto es requerido y no puede superar 150 caracteres.");
            }

            if (string.IsNullOrWhiteSpace(mensaje) || mensaje.Length > LongitudMaximaMensaje)
            {
                return CrearError("El mensaje es requerido y no puede superar 2000 caracteres.");
            }

            return await _empresaRepository.RegistrarMensajeAsync(request, idUsuario);
        }

        public async Task<PaginatedResponseDto<MensajeContactoResponseDto>> ObtenerMensajesAsync(
            string? estado,
            PaginationQuery pagination)
        {
            return await _empresaRepository.ObtenerMensajesAsync(estado, pagination);
        }

        private static bool EsCorreoValido(string correo)
        {
            if (string.IsNullOrWhiteSpace(correo))
            {
                return false;
            }

            var partes = correo.Trim().Split('@');
            return partes.Length == 2 &&
                   partes[0].Length > 0 &&
                   partes[1].Contains('.') &&
                   partes[1].Length >= 3;
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

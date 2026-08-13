using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;

namespace Concre_Innova_API.Application.Services
{
    public class ConsultaService : IConsultaService
    {
        private const int LongitudMinimaRespuesta = 10;
        private const int LongitudMaximaRespuesta = 2000;

        private readonly IEmpresaRepository _empresaRepository;
        private readonly IEmailService _emailService;
        private readonly ILogger<ConsultaService> _logger;

        public ConsultaService(
            IEmpresaRepository empresaRepository,
            IEmailService emailService,
            ILogger<ConsultaService> logger)
        {
            _empresaRepository = empresaRepository;
            _emailService = emailService;
            _logger = logger;
        }

        public Task<PaginatedResponseDto<MensajeContactoResponseDto>> ObtenerAsync(
            string? estado,
            PaginationQuery pagination)
        {
            return _empresaRepository.ObtenerMensajesAsync(estado, pagination);
        }

        public async Task<OperacionResponseDto> ResponderAsync(
            int idConsulta,
            ResponderConsultaRequest request,
            int idUsuario)
        {
            if (idConsulta <= 0)
            {
                return CrearError("La consulta indicada no es valida.");
            }

            var respuesta = request?.Respuesta?.Trim() ?? string.Empty;

            if (respuesta.Length < LongitudMinimaRespuesta)
            {
                return CrearError(
                    $"La respuesta debe tener al menos {LongitudMinimaRespuesta} caracteres.");
            }

            if (respuesta.Length > LongitudMaximaRespuesta)
            {
                return CrearError(
                    $"La respuesta no puede superar {LongitudMaximaRespuesta} caracteres.");
            }

            var resultado = await _empresaRepository.ResponderMensajeAsync(
                idConsulta,
                respuesta,
                idUsuario);

            if (!resultado.Exitoso)
            {
                return CrearError(
                    resultado.Mensaje == "MENSAJE_NO_EXISTE"
                        ? "La consulta no existe."
                        : "No fue posible registrar la respuesta.");
            }

            await EnviarRespuestaPorCorreoAsync(resultado.CorreoCliente, resultado.NombreCliente, resultado.Asunto, respuesta);

            return new OperacionResponseDto
            {
                Codigo = 1,
                Mensaje = "Consulta respondida correctamente."
            };
        }

        /// <summary>
        /// El correo es un aviso complementario: si falla, la respuesta ya quedo
        /// registrada y la operacion no debe darse por fallida.
        /// </summary>
        private async Task EnviarRespuestaPorCorreoAsync(
            string correo,
            string nombre,
            string asunto,
            string respuesta)
        {
            if (string.IsNullOrWhiteSpace(correo))
                return;

            try
            {
                await _emailService.SendContactReplyAsync(correo, nombre, asunto, respuesta);
            }
            catch (Exception exception)
            {
                _logger.LogWarning(
                    exception,
                    "La respuesta de la consulta se guardo pero no se pudo notificar por correo.");
            }
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

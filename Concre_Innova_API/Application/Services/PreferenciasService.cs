using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;

namespace Concre_Innova_API.Application.Services
{
    public class PreferenciasService : IPreferenciasService
    {
        private static readonly HashSet<string> TemasValidos = new(StringComparer.OrdinalIgnoreCase)
        {
            "claro",
            "oscuro"
        };

        private readonly IPreferenciasRepository _preferenciasRepository;

        public PreferenciasService(IPreferenciasRepository preferenciasRepository)
        {
            _preferenciasRepository = preferenciasRepository;
        }

        public async Task<PreferenciasUsuarioResponseDto> ObtenerAsync(int idUsuario)
        {
            return await _preferenciasRepository.ObtenerAsync(idUsuario);
        }

        public async Task<OperacionResponseDto> ActualizarAsync(
            int idUsuario,
            ActualizarPreferenciasRequest request)
        {
            if (request is null)
            {
                return new OperacionResponseDto
                {
                    Codigo = 0,
                    Mensaje = "La solicitud no es válida."
                };
            }

            var tema = string.IsNullOrWhiteSpace(request.Tema) ? "claro" : request.Tema.Trim();

            if (!TemasValidos.Contains(tema))
            {
                return new OperacionResponseDto
                {
                    Codigo = 0,
                    Mensaje = "El tema indicado no es válido."
                };
            }

            request.Tema = tema.ToLowerInvariant();

            return await _preferenciasRepository.ActualizarAsync(idUsuario, request);
        }
    }
}

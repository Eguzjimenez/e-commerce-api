using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Validators
{
    public interface IAsesorRequestValidator
    {
        string? ValidateRecomendacion(
            AsesorRecomendacionRequest? request,
            AsesorCuestionarioResponseDto cuestionario);
    }
}

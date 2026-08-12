using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Validators;

namespace Concre_Innova_API.Application.Validators
{
    public class AsesorRequestValidator : IAsesorRequestValidator
    {
        public string? ValidateRecomendacion(
            AsesorRecomendacionRequest? request,
            AsesorCuestionarioResponseDto cuestionario)
        {
            if (request is null || request.Respuestas.Count == 0)
                return "Responde todas las preguntas del cuestionario para obtener recomendaciones.";

            if (cuestionario.Preguntas.Count == 0)
                return "El cuestionario del asesor no esta disponible en este momento.";

            foreach (var pregunta in cuestionario.Preguntas)
            {
                var mensajePregunta = ValidateRespuestaDePregunta(request, pregunta);

                if (mensajePregunta is not null)
                    return mensajePregunta;
            }

            return null;
        }

        private static string? ValidateRespuestaDePregunta(
            AsesorRecomendacionRequest request,
            AsesorPreguntaResponseDto pregunta)
        {
            var respuestas = request.Respuestas
                .Where(respuesta => respuesta.IdPregunta == pregunta.IdPregunta)
                .ToList();

            if (respuestas.Count == 0)
                return $"Falta responder la pregunta: {pregunta.Texto}";

            if (respuestas.Count > 1)
                return $"Selecciona una sola respuesta para la pregunta: {pregunta.Texto}";

            var idOpcionSeleccionada = respuestas[0].IdOpcion;
            var perteneceALaPregunta = pregunta.Opciones
                .Any(opcion => opcion.IdOpcion == idOpcionSeleccionada);

            return perteneceALaPregunta
                ? null
                : $"La respuesta seleccionada no es valida para la pregunta: {pregunta.Texto}";
        }
    }
}

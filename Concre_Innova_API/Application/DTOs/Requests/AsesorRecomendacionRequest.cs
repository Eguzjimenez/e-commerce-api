namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class AsesorRecomendacionRequest
    {
        public List<AsesorRespuestaSeleccionadaDto> Respuestas { get; set; } = new();

        public int? LimitePorClasificacion { get; set; }

        public IReadOnlyList<int> ObtenerIdsOpcionSeleccionados()
        {
            return Respuestas
                .Where(respuesta => respuesta.IdOpcion > 0)
                .Select(respuesta => respuesta.IdOpcion)
                .Distinct()
                .ToList();
        }
    }

    public class AsesorRespuestaSeleccionadaDto
    {
        public int IdPregunta { get; set; }
        public int IdOpcion { get; set; }
    }
}

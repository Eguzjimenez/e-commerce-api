namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class AsesorCuestionarioResponseDto
    {
        public List<AsesorPreguntaResponseDto> Preguntas { get; set; } = new();
    }

    public class AsesorPreguntaResponseDto
    {
        public int IdPregunta { get; set; }
        public string Codigo { get; set; } = string.Empty;
        public string Texto { get; set; } = string.Empty;
        public string Ayuda { get; set; } = string.Empty;
        public int Orden { get; set; }
        public List<AsesorOpcionResponseDto> Opciones { get; set; } = new();
    }

    public class AsesorOpcionResponseDto
    {
        public int IdOpcion { get; set; }
        public int IdPregunta { get; set; }
        public string Codigo { get; set; } = string.Empty;
        public string Etiqueta { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public int Orden { get; set; }
    }
}

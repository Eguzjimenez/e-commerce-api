namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class AsesorRecomendacionResponseDto
    {
        public bool Exitoso { get; set; }
        public string Mensaje { get; set; } = string.Empty;
        public bool RespuestasGuardadas { get; set; }
        public List<AsesorGrupoRecomendacionResponseDto> Grupos { get; set; } = new();
    }

    public class AsesorGrupoRecomendacionResponseDto
    {
        public string Clasificacion { get; set; } = string.Empty;
        public List<AsesorProductoRecomendadoResponseDto> Productos { get; set; } = new();
    }

    public class AsesorProductoRecomendadoResponseDto
    {
        public int IdProducto { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public decimal Precio { get; set; }
        public string Imagen { get; set; } = string.Empty;
        public int IdCategoria { get; set; }
        public string NombreCategoria { get; set; } = string.Empty;
        public string NombreTipo { get; set; } = string.Empty;
        public string Tamano { get; set; } = string.Empty;
        public string Material { get; set; } = string.Empty;
        public int Stock { get; set; }
        public string Clasificacion { get; set; } = string.Empty;
        public int Puntaje { get; set; }
    }
}

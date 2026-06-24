namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class CategoriaResponseDto
    {
        public int IdCategoria { get; set; }
        public string NombreCategoria { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Estado { get; set; } = string.Empty;
    }
}

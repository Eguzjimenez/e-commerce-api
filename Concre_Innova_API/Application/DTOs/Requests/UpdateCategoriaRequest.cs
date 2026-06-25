namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class UpdateCategoriaRequest
    {
        public int IdCategoria { get; set; }
        public string NombreCategoria { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
        public string Estado { get; set; } = string.Empty;
    }
}

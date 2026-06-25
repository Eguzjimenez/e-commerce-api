namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class CreateCategoriaRequest
    {
        public string NombreCategoria { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
    }
}

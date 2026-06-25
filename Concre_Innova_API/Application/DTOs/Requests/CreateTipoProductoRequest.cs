namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class CreateTipoProductoRequest
    {
        public string NombreTipo { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
    }
}

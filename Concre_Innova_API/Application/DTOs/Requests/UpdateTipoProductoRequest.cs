namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class UpdateTipoProductoRequest
    {
        public int IdTipo { get; set; }
        public string NombreTipo { get; set; } = string.Empty;
        public string? Descripcion { get; set; }
        public string Estado { get; set; } = string.Empty;
    }
}

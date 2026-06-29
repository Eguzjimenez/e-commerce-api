namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class PermissionResponseDto
    {
        public int IdPermiso { get; set; }
        public string Codigo { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public string Modulo { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Asignado { get; set; }
    }
}

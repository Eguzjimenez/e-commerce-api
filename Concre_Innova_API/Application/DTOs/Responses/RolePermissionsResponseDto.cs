namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class RolePermissionsResponseDto
    {
        public int IdRol { get; set; }
        public string NombreRol { get; set; } = string.Empty;
        public IEnumerable<PermissionResponseDto> Permisos { get; set; } =
            Enumerable.Empty<PermissionResponseDto>();
    }
}

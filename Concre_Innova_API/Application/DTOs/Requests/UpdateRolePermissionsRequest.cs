namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class UpdateRolePermissionsRequest
    {
        public int IdRol { get; set; }
        public IEnumerable<int> IdPermisos { get; set; } = Enumerable.Empty<int>();
    }
}

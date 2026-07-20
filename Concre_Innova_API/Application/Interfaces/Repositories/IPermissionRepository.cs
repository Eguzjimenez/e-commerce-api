using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface IPermissionRepository
    {
        Task<bool> RoleHasPermissionAsync(int roleId, string permissionCode);
        Task<IEnumerable<RolePermissionsResponseDto>> GetRolePermissionsAsync();
        Task<RolePermissionsResponseDto?> GetRolePermissionsAsync(int roleId);
        Task<OperacionResponseDto> UpdateRolePermissionsAsync(UpdateRolePermissionsRequest request);
    }
}

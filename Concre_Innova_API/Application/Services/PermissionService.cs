using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;

namespace Concre_Innova_API.Application.Services
{
    public class PermissionService : IPermissionService
    {
        private readonly IPermissionRepository _permissionRepository;

        public PermissionService(IPermissionRepository permissionRepository)
        {
            _permissionRepository = permissionRepository;
        }

        public Task<bool> RoleHasPermissionAsync(int roleId, string permissionCode)
        {
            return _permissionRepository.RoleHasPermissionAsync(roleId, permissionCode);
        }

        public Task<IEnumerable<RolePermissionsResponseDto>> GetRolePermissionsAsync()
        {
            return _permissionRepository.GetRolePermissionsAsync();
        }

        public Task<RolePermissionsResponseDto?> GetRolePermissionsAsync(int roleId)
        {
            return _permissionRepository.GetRolePermissionsAsync(roleId);
        }

        public Task<OperacionResponseDto> UpdateRolePermissionsAsync(UpdateRolePermissionsRequest request)
        {
            return _permissionRepository.UpdateRolePermissionsAsync(request);
        }
    }
}

using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;
using Microsoft.Extensions.Caching.Memory;
using System.Collections.Concurrent;

namespace Concre_Innova_API.Application.Services
{
    public class PermissionService : IPermissionService
    {
        private static readonly ConcurrentDictionary<int, int> RolePermissionCacheVersions = new();
        private static readonly TimeSpan PermissionCacheDuration = TimeSpan.FromMinutes(5);

        private readonly IPermissionRepository _permissionRepository;
        private readonly IMemoryCache _cache;

        public PermissionService(
            IPermissionRepository permissionRepository,
            IMemoryCache cache)
        {
            _permissionRepository = permissionRepository;
            _cache = cache;
        }

        public Task<bool> RoleHasPermissionAsync(int roleId, string permissionCode)
        {
            var normalizedPermissionCode = string.IsNullOrWhiteSpace(permissionCode)
                ? string.Empty
                : permissionCode.Trim();

            if (string.IsNullOrWhiteSpace(normalizedPermissionCode))
            {
                return Task.FromResult(false);
            }

            var cacheKey = GetRolePermissionCacheKey(roleId, normalizedPermissionCode);

            return _cache.GetOrCreateAsync(cacheKey, entry =>
            {
                entry.AbsoluteExpirationRelativeToNow = PermissionCacheDuration;
                return _permissionRepository.RoleHasPermissionAsync(roleId, normalizedPermissionCode);
            })!;
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
            return UpdateRolePermissionsAndInvalidateCacheAsync(request);
        }

        private async Task<OperacionResponseDto> UpdateRolePermissionsAndInvalidateCacheAsync(
            UpdateRolePermissionsRequest request)
        {
            var result = await _permissionRepository.UpdateRolePermissionsAsync(request);

            if (result.Codigo == 1)
            {
                RolePermissionCacheVersions.AddOrUpdate(
                    request.IdRol,
                    _ => 1,
                    (_, currentVersion) => currentVersion + 1);
            }

            return result;
        }

        private static string GetRolePermissionCacheKey(int roleId, string permissionCode)
        {
            var version = RolePermissionCacheVersions.GetOrAdd(roleId, 0);
            return $"permissions:role:{roleId}:version:{version}:code:{permissionCode}";
        }
    }
}

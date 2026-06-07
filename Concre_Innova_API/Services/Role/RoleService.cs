using Concre_Innova_API.Models.DTOs.Responses;
using Concre_Innova_API.Repositories.Roles;
using System.Collections.Generic;

namespace Concre_Innova_API.Services.Role
{
    public class RoleService : IRoleService
    {
        private readonly IRoleRepository _repo;

        public RoleService(IRoleRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<RoleResponseDto>> GetRolesAsync()
        {
            return _repo.GetRolesAsync();
        }
    }
}

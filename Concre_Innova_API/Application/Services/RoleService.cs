using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;
using System.Collections.Generic;

namespace Concre_Innova_API.Application.Services
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

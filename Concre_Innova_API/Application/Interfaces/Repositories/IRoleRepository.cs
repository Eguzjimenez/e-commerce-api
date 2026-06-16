using Concre_Innova_API.Application.DTOs.Responses;
using System.Collections.Generic;

namespace Concre_Innova_API.Application.Interfaces.Repositories
{
    public interface IRoleRepository
    {
        Task<IEnumerable<RoleResponseDto>> GetRolesAsync();
    }
}

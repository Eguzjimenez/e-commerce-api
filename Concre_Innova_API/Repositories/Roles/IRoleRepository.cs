using Concre_Innova_API.Models.DTOs.Responses;
using System.Collections.Generic;

namespace Concre_Innova_API.Repositories.Roles
{
    public interface IRoleRepository
    {
        Task<IEnumerable<RoleResponseDto>> GetRolesAsync();
    }
}

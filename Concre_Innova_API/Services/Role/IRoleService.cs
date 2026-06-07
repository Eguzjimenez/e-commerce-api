using Concre_Innova_API.Models.DTOs.Responses;
using System.Collections.Generic;

namespace Concre_Innova_API.Services.Role
{
    public interface IRoleService
    {
        Task<IEnumerable<RoleResponseDto>> GetRolesAsync();
    }
}

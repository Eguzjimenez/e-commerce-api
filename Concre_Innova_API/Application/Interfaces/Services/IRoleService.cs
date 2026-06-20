using Concre_Innova_API.Application.DTOs.Responses;
using System.Collections.Generic;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface IRoleService
    {
        Task<IEnumerable<RoleResponseDto>> GetRolesAsync();
    }
}

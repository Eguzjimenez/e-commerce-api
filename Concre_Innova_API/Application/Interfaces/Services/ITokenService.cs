using System.Security.Claims;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface ITokenService
    {
        string GenerateToken(IEnumerable<Claim> claims);
    }
}

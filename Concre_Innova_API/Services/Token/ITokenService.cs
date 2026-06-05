using System.Security.Claims;

namespace Concre_Innova_API.Services.Token
{
    public interface ITokenService
    {
        string GenerateToken(IEnumerable<Claim> claims);
    }
}

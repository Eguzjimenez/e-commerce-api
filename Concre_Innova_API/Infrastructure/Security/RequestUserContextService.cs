using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Security;
using Concre_Innova_API.Domain.Constants;
using System.Security.Claims;

namespace Concre_Innova_API.Infrastructure.Security
{
    public class RequestUserContextService : IRequestUserContextService
    {
        public RequestUserContext GetCurrentUser(HttpContext httpContext)
        {
            int? userId = ReadClaimInt(httpContext.User, ClaimTypes.NameIdentifier);
            int? roleId = ReadClaimInt(httpContext.User, "idRol");

            return new RequestUserContext
            {
                UserId = userId,
                RoleId = roleId,
                RoleName = httpContext.User.FindFirstValue("nombreRol") ?? AppRoles.GetName(roleId),
                IpAddress = httpContext.Connection.RemoteIpAddress?.ToString() ?? string.Empty
            };
        }

        private static int? ReadClaimInt(ClaimsPrincipal user, string claimType)
        {
            var value = user.FindFirstValue(claimType);

            return int.TryParse(value, out var result) ? result : null;
        }
    }
}

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
            int? userId = ReadClaimInt(
                httpContext.User,
                ClaimTypes.NameIdentifier,
                "nameid",
                "sub");
            int? roleId = ReadClaimInt(httpContext.User, "idRol");

            return new RequestUserContext
            {
                UserId = userId,
                RoleId = roleId,
                RoleName =
                    httpContext.User.FindFirstValue("nombreRol") ??
                    httpContext.User.FindFirstValue(ClaimTypes.Role) ??
                    httpContext.User.FindFirstValue("role") ??
                    AppRoles.GetName(roleId),
                IpAddress = httpContext.Connection.RemoteIpAddress?.ToString() ?? string.Empty,
                HasAuthenticatedIdentity = httpContext.User.Identity?.IsAuthenticated == true
            };
        }

        private static int? ReadClaimInt(ClaimsPrincipal user, params string[] claimTypes)
        {
            var value = claimTypes
                .Select(user.FindFirstValue)
                .FirstOrDefault(claimValue => !string.IsNullOrWhiteSpace(claimValue));

            return int.TryParse(value, out var result) ? result : null;
        }
    }
}

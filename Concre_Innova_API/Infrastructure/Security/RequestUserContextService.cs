using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Security;
using Concre_Innova_API.Domain.Constants;

namespace Concre_Innova_API.Infrastructure.Security
{
    public class RequestUserContextService : IRequestUserContextService
    {
        public RequestUserContext GetCurrentUser(HttpContext httpContext)
        {
            int? userId = ReadHeaderInt(httpContext, "X-User-Id");
            int? roleId = ReadHeaderInt(httpContext, "X-User-Role");

            return new RequestUserContext
            {
                UserId = userId,
                RoleId = roleId,
                RoleName = AppRoles.GetName(roleId),
                IpAddress = httpContext.Connection.RemoteIpAddress?.ToString() ?? string.Empty
            };
        }

        private static int? ReadHeaderInt(HttpContext httpContext, string headerName)
        {
            if (!httpContext.Request.Headers.TryGetValue(headerName, out var value))
                return null;

            return int.TryParse(value.ToString(), out var result) ? result : null;
        }
    }
}

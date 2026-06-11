using Concre_Innova_API.Security;

namespace Concre_Innova_API.Services.Security
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

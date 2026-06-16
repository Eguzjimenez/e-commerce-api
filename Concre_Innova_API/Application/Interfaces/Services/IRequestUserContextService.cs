using Concre_Innova_API.Application.Security;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface IRequestUserContextService
    {
        RequestUserContext GetCurrentUser(HttpContext httpContext);
    }
}

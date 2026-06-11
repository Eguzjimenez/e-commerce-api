namespace Concre_Innova_API.Services.Security
{
    public interface IRequestUserContextService
    {
        RequestUserContext GetCurrentUser(HttpContext httpContext);
    }
}

using Concre_Innova_API.Application.Security;

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface IAuditService
    {
        Task RecordAsync(RequestUserContext userContext, string module, string operation, string description);
        Task RecordLoginAttemptAsync(int? userId, string email, bool wasSuccessful, string ipAddress, string description);
    }
}

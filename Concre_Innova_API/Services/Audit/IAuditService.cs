using Concre_Innova_API.Services.Security;

namespace Concre_Innova_API.Services.Audit
{
    public interface IAuditService
    {
        Task RecordAsync(RequestUserContext userContext, string module, string operation, string description);
    }
}

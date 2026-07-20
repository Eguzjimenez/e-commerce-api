namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface ILoginAttemptService
    {
        bool IsBlocked(string email, out DateTime? blockedUntil);
        void RecordFailedAttempt(string email);
        void ResetAttempts(string email);
    }
}

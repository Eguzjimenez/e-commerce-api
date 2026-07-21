namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface IEmailService
    {
        Task SendWelcomeEmailAsync(string toEmail, string name);
        Task SendPasswordRecoveryCodeAsync(string toEmail, string code, DateTime expiresAt);
        Task SendPasswordResetNotificationAsync(string toEmail, DateTime changedAt);
    }
}

namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface IEmailService
    {
        Task SendWelcomeEmailAsync(string toEmail, string name);
        Task SendPasswordRecoveryCodeAsync(string toEmail, string code, DateTime expiresAt);
        Task SendPasswordResetNotificationAsync(string toEmail, DateTime changedAt);
        Task<bool> SendContactReplyAsync(
            string toEmail,
            string customerName,
            string subject,
            string reply);

        Task<bool> SendQuotationStatusChangedAsync(
            string toEmail,
            string customerName,
            string trackingNumber,
            string previousStatus,
            string newStatus,
            DateTime changedAt);
    }
}

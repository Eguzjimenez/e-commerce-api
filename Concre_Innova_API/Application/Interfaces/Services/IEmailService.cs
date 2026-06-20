namespace Concre_Innova_API.Application.Interfaces.Services
{
    public interface IEmailService
    {
        Task SendWelcomeEmailAsync(string toEmail, string name);
        Task SendPasswordResetNotificationAsync(string toEmail, DateTime changedAt);
    }
}

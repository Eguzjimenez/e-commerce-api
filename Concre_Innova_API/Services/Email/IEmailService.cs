namespace Concre_Innova_API.Services.Email
{
    public interface IEmailService
    {
        Task SendWelcomeEmailAsync(string toEmail, string name);
    }
}

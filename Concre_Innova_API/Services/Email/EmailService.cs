using System.Net;
using System.Net.Mail;

namespace Concre_Innova_API.Services.Email
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<EmailService> _logger;

        public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        public async Task SendWelcomeEmailAsync(string toEmail, string name)
        {
            var host = _configuration["Email:SmtpHost"];
            var from = _configuration["Email:From"];

            if (string.IsNullOrWhiteSpace(host) || string.IsNullOrWhiteSpace(from))
            {
                _logger.LogInformation("Correo de bienvenida simulado para {Email}.", toEmail);
                return;
            }

            using var message = new MailMessage(from, toEmail)
            {
                Subject = "Bienvenido a Concre Innova",
                Body = $"Hola {name}, tu cuenta de cliente en Concre Innova fue creada correctamente."
            };

            using var client = new SmtpClient(host)
            {
                Port = int.TryParse(_configuration["Email:SmtpPort"], out var port) ? port : 587,
                EnableSsl = bool.TryParse(_configuration["Email:EnableSsl"], out var ssl) && ssl
            };

            var user = _configuration["Email:Username"];
            var password = _configuration["Email:Password"];
            if (!string.IsNullOrWhiteSpace(user) && !string.IsNullOrWhiteSpace(password))
                client.Credentials = new NetworkCredential(user, password);

            try
            {
                await client.SendMailAsync(message);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "No se pudo enviar el correo de bienvenida a {Email}.", toEmail);
            }
        }
    }
}

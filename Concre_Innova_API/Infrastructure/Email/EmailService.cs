using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Configuration.Settings;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Options;
using MimeKit;

namespace Concre_Innova_API.Infrastructure.Email
{
    public class EmailService : IEmailService
    {
        private readonly EmailSettings _settings;
        private readonly ILogger<EmailService> _logger;

        public EmailService(IOptions<EmailSettings> settings, ILogger<EmailService> logger)
        {
            _settings = settings.Value;
            _logger = logger;
        }

        public async Task SendWelcomeEmailAsync(string toEmail, string name)
        {
            await SendEmailAsync(
                toEmail,
                "Bienvenido a Concre Innova",
                $"Hola {name}, tu cuenta de cliente en Concre Innova fue creada correctamente.");
        }

        public async Task SendPasswordResetNotificationAsync(string toEmail, DateTime changedAt)
        {
            var body =
                "Your password was successfully reset. If this was you, no action is needed. If this was not you, please contact support immediately." +
                Environment.NewLine +
                Environment.NewLine +
                $"Date/time: {changedAt:yyyy-MM-dd HH:mm:ss} UTC";

            await SendEmailAsync(
                toEmail,
                "Password reset notification",
                body);
        }

        private async Task SendEmailAsync(string toEmail, string subject, string body)
        {
            if (string.IsNullOrWhiteSpace(_settings.Host) ||
                string.IsNullOrWhiteSpace(_settings.SenderEmail))
            {
                _logger.LogInformation(
                    "Correo simulado para {Email}. Asunto: {Subject}",
                    toEmail,
                    subject);
                return;
            }

            var message = new MimeMessage();
            message.From.Add(new MailboxAddress(
                _settings.SenderName ?? "Concre Innova",
                _settings.SenderEmail));
            message.To.Add(MailboxAddress.Parse(toEmail));
            message.Subject = subject;
            message.Body = new TextPart("plain") { Text = body };

            try
            {
                using var client = new SmtpClient();
                var socketOptions = _settings.UseSsl
                    ? SecureSocketOptions.SslOnConnect
                    : SecureSocketOptions.StartTlsWhenAvailable;

                await client.ConnectAsync(_settings.Host, _settings.Port, socketOptions);

                if (!string.IsNullOrWhiteSpace(_settings.Username) &&
                    !string.IsNullOrWhiteSpace(_settings.Password))
                {
                    await client.AuthenticateAsync(_settings.Username, _settings.Password);
                }

                await client.SendAsync(message);
                await client.DisconnectAsync(true);

                _logger.LogInformation(
                    "Correo {Subject} enviado a {Email}.",
                    subject,
                    toEmail);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(
                    ex,
                    "No se pudo enviar el correo {Subject} a {Email}.",
                    subject,
                    toEmail);
            }
        }
    }
}

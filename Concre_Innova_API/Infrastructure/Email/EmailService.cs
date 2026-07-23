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
        private const int MaximoIntentosPorLimiteSmtp = 3;
        private static readonly TimeSpan EsperaPorLimiteSmtp =
            TimeSpan.FromMilliseconds(2100);
        private static readonly TimeSpan IntervaloMinimoEntreEnvios =
            TimeSpan.FromSeconds(6);
        private static readonly SemaphoreSlim SmtpSendGate = new(1, 1);
        private static DateTime _ultimoEnvioUtc = DateTime.MinValue;

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

        public async Task SendPasswordRecoveryCodeAsync(string toEmail, string code, DateTime expiresAt)
        {
            var body =
                "Hola," +
                Environment.NewLine +
                Environment.NewLine +
                "Recibimos una solicitud para restablecer la contrasena de tu cuenta en Concre Innova." +
                Environment.NewLine +
                $"Tu codigo de verificacion es: {code}" +
                Environment.NewLine +
                $"Este codigo expira el {expiresAt:yyyy-MM-dd HH:mm:ss} UTC." +
                Environment.NewLine +
                Environment.NewLine +
                "Si no solicitaste este cambio, puedes ignorar este correo.";

            await SendEmailAsync(
                toEmail,
                "Codigo de recuperacion de contrasena",
                body);
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

        public Task<bool> SendQuotationStatusChangedAsync(
            string toEmail,
            string customerName,
            string trackingNumber,
            string previousStatus,
            string newStatus,
            DateTime changedAt)
        {
            var body =
                $"Hola {customerName}," +
                Environment.NewLine +
                Environment.NewLine +
                $"La cotizacion {trackingNumber} cambio de " +
                $"{previousStatus} a {newStatus}." +
                Environment.NewLine +
                $"Fecha del cambio: {changedAt:yyyy-MM-dd HH:mm:ss}." +
                Environment.NewLine +
                Environment.NewLine +
                "Puedes consultar el detalle y su historial de estados en " +
                "la seccion Mis Cotizaciones.";

            return SendEmailAsync(
                toEmail,
                $"Cotizacion {trackingNumber}: {newStatus}",
                body);
        }

        private async Task<bool> SendEmailAsync(
            string toEmail,
            string subject,
            string body)
        {
            if (string.IsNullOrWhiteSpace(_settings.Host) ||
                string.IsNullOrWhiteSpace(_settings.SenderEmail))
            {
                _logger.LogInformation(
                    "Correo simulado para {Email}. Asunto: {Subject}",
                    toEmail,
                    subject);
                return true;
            }

            for (var attempt = 1; attempt <= MaximoIntentosPorLimiteSmtp; attempt++)
            {
                try
                {
                    var message = CrearMensaje(toEmail, subject, body);
                    await EnviarMensajeAsync(message);

                    _logger.LogInformation(
                        "Correo {Subject} enviado a {Email}.",
                        subject,
                        toEmail);
                    return true;
                }
                catch (SmtpCommandException exception)
                    when (EsLimiteTemporal(exception) &&
                          attempt < MaximoIntentosPorLimiteSmtp)
                {
                    await Task.Delay(EsperaPorLimiteSmtp);
                }
                catch (Exception exception)
                {
                    _logger.LogWarning(
                        exception,
                        "No se pudo enviar el correo {Subject} a {Email}.",
                        subject,
                        toEmail);
                    return false;
                }
            }

            return false;
        }

        private MimeMessage CrearMensaje(
            string toEmail,
            string subject,
            string body)
        {
            var message = new MimeMessage();
            message.From.Add(new MailboxAddress(
                _settings.SenderName ?? "Concre Innova",
                _settings.SenderEmail!));
            message.To.Add(MailboxAddress.Parse(toEmail));
            message.Subject = subject;
            message.Body = new TextPart("plain") { Text = body };
            return message;
        }

        private async Task EnviarMensajeAsync(MimeMessage message)
        {
            await SmtpSendGate.WaitAsync();
            try
            {
                var elapsed = DateTime.UtcNow - _ultimoEnvioUtc;
                var remainingDelay = IntervaloMinimoEntreEnvios - elapsed;
                if (remainingDelay > TimeSpan.Zero)
                {
                    await Task.Delay(remainingDelay);
                }

                using var client = new SmtpClient();
                var socketOptions = _settings.UseSsl
                    ? SecureSocketOptions.SslOnConnect
                    : SecureSocketOptions.StartTlsWhenAvailable;

                await client.ConnectAsync(
                    _settings.Host!,
                    _settings.Port,
                    socketOptions);

                if (!string.IsNullOrWhiteSpace(_settings.Username) &&
                    !string.IsNullOrWhiteSpace(_settings.Password))
                {
                    await client.AuthenticateAsync(
                        _settings.Username,
                        _settings.Password);
                }

                await client.SendAsync(message);
                await client.DisconnectAsync(true);
                _ultimoEnvioUtc = DateTime.UtcNow;
            }
            finally
            {
                SmtpSendGate.Release();
            }
        }

        private static bool EsLimiteTemporal(SmtpCommandException exception)
        {
            return exception.Message.Contains(
                "Too many emails per second",
                StringComparison.OrdinalIgnoreCase);
        }
    }
}

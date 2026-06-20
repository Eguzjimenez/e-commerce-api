namespace Concre_Innova_API.Configuration.Settings
{
    public class EmailSettings
    {
        public string? Host { get; set; }
        public int Port { get; set; } = 2525;
        public string? Username { get; set; }
        public string? Password { get; set; }
        public string? SenderEmail { get; set; }
        public string? SenderName { get; set; }
        public bool UseSsl { get; set; }
    }
}

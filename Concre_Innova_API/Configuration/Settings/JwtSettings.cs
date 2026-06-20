namespace Concre_Innova_API.Configuration.Settings
{
    public class JwtSettings
    {
        public string? Key { get; set; }
        public string? Issuer { get; set; }
        public string? Audience { get; set; }
        public int ExpireMinutes { get; set; } = 10;
    }
}

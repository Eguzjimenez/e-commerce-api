namespace Concre_Innova_API.Application.DTOs.Requests.Login
{
    public class RecoveryCodeVerificationRequest
    {
        public string? Correo { get; set; }
        public string? Codigo { get; set; }
    }
}

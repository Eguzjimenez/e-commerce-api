namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class RecoveryCodeVerificationResponseDto
    {
        public int Codigo { get; set; }
        public string? Mensaje { get; set; }
        public string? RecoveryToken { get; set; }
    }
}

namespace Concre_Innova_API.Application.DTOs.Requests.Login
{
    public class PasswordResetRequest
    {
        public int IdUsuario { get; set; }
        public string? RecoveryToken { get; set; }
        public string? NuevaContrasena { get; set; }
    }
}

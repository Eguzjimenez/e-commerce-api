namespace Concre_Innova_API.Models.DTOs.Requests.Login
{
    public class PasswordResetRequest
    {
        public int IdUsuario { get; set; }
        public string? NuevaContrasena { get; set; }
    }
}

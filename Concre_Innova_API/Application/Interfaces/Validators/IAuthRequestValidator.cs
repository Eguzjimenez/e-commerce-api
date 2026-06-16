using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Requests.Login;

namespace Concre_Innova_API.Application.Interfaces.Validators
{
    public interface IAuthRequestValidator
    {
        string? ValidateLogin(UserLoginDto? request);
        string? ValidateClientRegistration(RegisterClientRequest? request);
        string? ValidateEmail(EmailValidationRequest? request);
        string? ValidateRecoveryEmail(EmailValidationRequest? request);
        string? ValidatePasswordReset(PasswordResetRequest? request);
        string? ValidateRecoveryToken(string? token);
    }
}

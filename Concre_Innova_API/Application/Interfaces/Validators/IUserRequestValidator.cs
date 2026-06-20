using Concre_Innova_API.Application.DTOs.Requests;

namespace Concre_Innova_API.Application.Interfaces.Validators
{
    public interface IUserRequestValidator
    {
        string? ValidateCreate(CreateUserRequest? request);
        string? ValidateUpdate(UpdateUserRequest? request);
    }
}

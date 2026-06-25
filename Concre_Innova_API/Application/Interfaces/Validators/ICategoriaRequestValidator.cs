using Concre_Innova_API.Application.DTOs.Requests;

namespace Concre_Innova_API.Application.Interfaces.Validators
{
    public interface ICategoriaRequestValidator
    {
        string? ValidateCreate(CreateCategoriaRequest? request);
        string? ValidateUpdate(UpdateCategoriaRequest? request);
    }
}

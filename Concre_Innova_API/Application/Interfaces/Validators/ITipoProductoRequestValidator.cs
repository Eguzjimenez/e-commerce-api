using Concre_Innova_API.Application.DTOs.Requests;

namespace Concre_Innova_API.Application.Interfaces.Validators
{
    public interface ITipoProductoRequestValidator
    {
        string? ValidateCreate(CreateTipoProductoRequest? request);
        string? ValidateUpdate(UpdateTipoProductoRequest? request);
    }
}

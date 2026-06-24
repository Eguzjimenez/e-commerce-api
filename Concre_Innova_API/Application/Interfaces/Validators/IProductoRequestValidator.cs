using Concre_Innova_API.Application.DTOs.Requests;

namespace Concre_Innova_API.Application.Interfaces.Validators
{
    public interface IProductoRequestValidator
    {
        string? ValidateCreate(CreateProductoRequest? request);
        string? ValidateUpdate(UpdateProductoRequest? request);
    }
}

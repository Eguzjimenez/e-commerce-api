using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.Interfaces.Validators;

namespace Concre_Innova_API.Application.Validators
{
    public class CategoriaRequestValidator : ICategoriaRequestValidator
    {
        public string? ValidateCreate(CreateCategoriaRequest? request)
        {
            if (request is null)
                return "Los datos de la categoria son requeridos.";

            return ValidateCategoryFields(request.NombreCategoria, request.Descripcion);
        }

        public string? ValidateUpdate(UpdateCategoriaRequest? request)
        {
            if (request is null)
                return "Los datos de la categoria son requeridos.";

            if (request.IdCategoria <= 0)
                return "El identificador de la categoria es requerido.";

            if (string.IsNullOrWhiteSpace(request.Estado))
                return "El estado de la categoria es requerido.";

            return ValidateCategoryFields(request.NombreCategoria, request.Descripcion);
        }

        private static string? ValidateCategoryFields(string nombreCategoria, string? descripcion)
        {
            if (string.IsNullOrWhiteSpace(nombreCategoria))
                return "El nombre de la categoria es requerido.";

            if (nombreCategoria.Trim().Length > 100)
                return "El nombre de la categoria no puede superar 100 caracteres.";

            if (!string.IsNullOrWhiteSpace(descripcion) && descripcion.Trim().Length > 255)
                return "La descripcion de la categoria no puede superar 255 caracteres.";

            return null;
        }
    }
}

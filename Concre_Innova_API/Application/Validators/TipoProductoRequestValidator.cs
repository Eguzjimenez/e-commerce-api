using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.Interfaces.Validators;

namespace Concre_Innova_API.Application.Validators
{
    public class TipoProductoRequestValidator : ITipoProductoRequestValidator
    {
        public string? ValidateCreate(CreateTipoProductoRequest? request)
        {
            if (request is null)
                return "Los datos del tipo de producto son requeridos.";

            return ValidateTipoFields(request.NombreTipo, request.Descripcion);
        }

        public string? ValidateUpdate(UpdateTipoProductoRequest? request)
        {
            if (request is null)
                return "Los datos del tipo de producto son requeridos.";

            if (request.IdTipo <= 0)
                return "El identificador del tipo de producto es requerido.";

            if (string.IsNullOrWhiteSpace(request.Estado))
                return "El estado del tipo de producto es requerido.";

            return ValidateTipoFields(request.NombreTipo, request.Descripcion);
        }

        private static string? ValidateTipoFields(string nombreTipo, string? descripcion)
        {
            if (string.IsNullOrWhiteSpace(nombreTipo))
                return "El nombre del tipo de producto es requerido.";

            if (nombreTipo.Trim().Length > 100)
                return "El nombre del tipo de producto no puede superar 100 caracteres.";

            if (!string.IsNullOrWhiteSpace(descripcion) && descripcion.Trim().Length > 255)
                return "La descripción del tipo de producto no puede superar 255 caracteres.";

            return null;
        }
    }
}

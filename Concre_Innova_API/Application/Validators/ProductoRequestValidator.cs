using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.Interfaces.Validators;

namespace Concre_Innova_API.Application.Validators
{
    public class ProductoRequestValidator : IProductoRequestValidator
    {
        public string? ValidateCreate(CreateProductoRequest? request)
        {
            if (request is null)
                return "Los datos del producto son requeridos.";

            return ValidateProductFields(
                request.Nombre,
                request.Precio,
                request.IdCategoria,
                request.CantidadDisponible,
                request.CantidadMinima);
        }

        public string? ValidateUpdate(UpdateProductoRequest? request)
        {
            if (request is null)
                return "Los datos del producto son requeridos.";

            if (request.IdProducto <= 0)
                return "El identificador del producto es requerido.";

            if (string.IsNullOrWhiteSpace(request.Estado))
                return "El estado del producto es requerido.";

            return ValidateProductFields(
                request.Nombre,
                request.Precio,
                request.IdCategoria,
                request.CantidadDisponible,
                request.CantidadMinima);
        }

        private static string? ValidateProductFields(
            string nombre,
            decimal precio,
            int idCategoria,
            int cantidadDisponible,
            int cantidadMinima)
        {
            if (string.IsNullOrWhiteSpace(nombre))
                return "El nombre del producto es requerido.";

            if (precio < 0)
                return "El precio del producto no puede ser negativo.";

            if (idCategoria <= 0)
                return "La categoria del producto es requerida.";

            if (cantidadDisponible < 0)
                return "La cantidad disponible no puede ser negativa.";

            if (cantidadMinima < 0)
                return "La cantidad minima no puede ser negativa.";

            return null;
        }
    }
}

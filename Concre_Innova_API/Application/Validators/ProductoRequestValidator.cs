using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.Interfaces.Validators;
using Concre_Innova_API.Domain.Constants;

namespace Concre_Innova_API.Application.Validators
{
    public class ProductoRequestValidator : IProductoRequestValidator
    {
        private static readonly HashSet<string> EstadosValidos = new(StringComparer.OrdinalIgnoreCase)
        {
            ProductoEstados.Activo,
            ProductoEstados.Inactivo,
            ProductoEstados.Borrador
        };

        public string? ValidateCreate(CreateProductoRequest? request)
        {
            if (request is null)
                return "Los datos del producto son requeridos.";

            return ValidateProductFields(
                request.Nombre,
                request.Precio,
                request.IdCategoria,
                request.IdTipo,
                request.Tamano,
                request.Material,
                request.Caracteristicas,
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

            if (!EstadosValidos.Contains(request.Estado.Trim()))
                return "El estado del producto no es valido.";

            return ValidateProductFields(
                request.Nombre,
                request.Precio,
                request.IdCategoria,
                request.IdTipo,
                request.Tamano,
                request.Material,
                request.Caracteristicas,
                request.CantidadDisponible,
                request.CantidadMinima);
        }

        private static string? ValidateProductFields(
            string nombre,
            decimal precio,
            int idCategoria,
            int? idTipo,
            string? tamano,
            string? material,
            string? caracteristicas,
            int cantidadDisponible,
            int cantidadMinima)
        {
            if (string.IsNullOrWhiteSpace(nombre))
                return "El nombre del producto es requerido.";

            if (precio <= 0)
                return "El precio del producto debe ser un valor numerico mayor a cero.";

            if (idCategoria <= 0)
                return "La categoria del producto es requerida.";

            if (idTipo.HasValue && idTipo.Value <= 0)
                return "El tipo de producto seleccionado no es valido.";

            if (HasInvalidAttributeLength(tamano))
                return "El tamano del producto no puede superar 80 caracteres.";

            if (HasInvalidAttributeLength(material))
                return "El material del producto no puede superar 80 caracteres.";

            if (!string.IsNullOrWhiteSpace(caracteristicas) && caracteristicas.Trim().Length > 500)
                return "Las caracteristicas del producto no pueden superar 500 caracteres.";

            if (cantidadDisponible < 0)
                return "La cantidad disponible no puede ser negativa.";

            if (cantidadMinima < 0)
                return "La cantidad minima no puede ser negativa.";

            return null;
        }

        private static bool HasInvalidAttributeLength(string? value)
        {
            return !string.IsNullOrWhiteSpace(value) && value.Trim().Length > 80;
        }
    }
}

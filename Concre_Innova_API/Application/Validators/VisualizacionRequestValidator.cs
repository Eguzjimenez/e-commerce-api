using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.Interfaces.Validators;
using Concre_Innova_API.Application.Models;
using Concre_Innova_API.Domain.Constants;

namespace Concre_Innova_API.Application.Validators
{
    public class VisualizacionRequestValidator : IVisualizacionRequestValidator
    {
        public string? ValidateImagenEspacio(ImagenEspacioUpload? imagen, string extension)
        {
            if (imagen is null || imagen.Contenido.Length == 0)
                return "Selecciona una imagen de tu espacio.";

            if (imagen.Contenido.LongLength > ImagenUsuarioRules.MaximoBytesPorImagen)
                return "La imagen del espacio no puede superar 5 MB.";

            if (!ImagenUsuarioRules.EsFormatoPermitido(extension, imagen.TipoContenido))
                return "Formato de imagen no permitido. Usa JPG, PNG o WEBP.";

            return null;
        }

        public string? ValidateGuardar(GuardarVisualizacionRequest? request)
        {
            if (request is null)
                return "Los datos de la visualización son requeridos.";

            if (string.IsNullOrWhiteSpace(request.Nombre))
                return "Asigna un nombre a la visualización.";

            if (request.Nombre.Trim().Length > VisualizacionRules.MaximoCaracteresNombre)
                return $"El nombre no puede superar {VisualizacionRules.MaximoCaracteresNombre} caracteres.";

            if (string.IsNullOrWhiteSpace(request.RutaImagenEspacio))
                return "Sube la imagen de tu espacio antes de guardar la visualización.";

            if (request.AnchoLienzo <= 0 || request.AltoLienzo <= 0)
                return "Las dimensiones de la visualización no son validas.";

            if (request.Productos.Count == 0)
                return "Agrega al menos un producto a la simulación.";

            if (request.Productos.Count > VisualizacionRules.MaximoProductosPorVisualizacion)
                return $"Puedes guardar hasta {VisualizacionRules.MaximoProductosPorVisualizacion} productos por visualización.";

            return ValidateProductos(request.Productos);
        }

        private static string? ValidateProductos(
            IReadOnlyList<VisualizacionProductoRequestDto> productos)
        {
            foreach (var producto in productos)
            {
                var mensaje = ValidateProducto(producto);

                if (mensaje is not null)
                    return mensaje;
            }

            return null;
        }

        private static string? ValidateProducto(VisualizacionProductoRequestDto producto)
        {
            if (producto.IdProducto <= 0)
                return "Uno de los productos de la simulación no es válido.";

            if (producto.Cantidad <= 0 ||
                producto.Cantidad > VisualizacionRules.MaximoCantidadPorProducto)
            {
                return $"La cantidad debe estar entre 1 y {VisualizacionRules.MaximoCantidadPorProducto}.";
            }

            if (producto.Ancho <= 0 || producto.Alto <= 0)
                return "El tamaño de un producto en la simulación no es válido.";

            if (producto.Color.Length > VisualizacionRules.MaximoCaracteresColor)
                return $"El color no puede superar {VisualizacionRules.MaximoCaracteresColor} caracteres.";

            if (producto.Macetero.Length > VisualizacionRules.MaximoCaracteresMacetero)
                return $"El macetero no puede superar {VisualizacionRules.MaximoCaracteresMacetero} caracteres.";

            return null;
        }
    }
}

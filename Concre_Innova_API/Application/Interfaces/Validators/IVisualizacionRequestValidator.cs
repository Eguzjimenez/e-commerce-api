using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.Models;

namespace Concre_Innova_API.Application.Interfaces.Validators
{
    public interface IVisualizacionRequestValidator
    {
        string? ValidateImagenEspacio(ImagenEspacioUpload? imagen, string extension);

        string? ValidateGuardar(GuardarVisualizacionRequest? request);
    }
}

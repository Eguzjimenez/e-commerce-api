namespace Concre_Innova_API.Application.Models
{
    /// <summary>
    /// Imagen del espacio recibida desde el cliente antes de almacenarse.
    /// </summary>
    public class ImagenEspacioUpload
    {
        public string NombreOriginal { get; set; } = string.Empty;
        public string TipoContenido { get; set; } = string.Empty;
        public byte[] Contenido { get; set; } = Array.Empty<byte>();
    }

    /// <summary>
    /// Resultado de guardar una visualizacion, incluida la imagen que quedo
    /// en desuso cuando el usuario reemplazo la foto del espacio.
    /// </summary>
    public class VisualizacionGuardada
    {
        public bool Exitoso { get; set; }
        public string Mensaje { get; set; } = string.Empty;
        public int? IdVisualizacion { get; set; }
        public string? RutaImagenAnterior { get; set; }
    }
}

namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class CrearCotizacionRequestDto
    {
        public string Descripcion { get; set; } = string.Empty;
        public string Preferencias { get; set; } = string.Empty;
        public List<SolicitudCotizacionProductoRequestDto> Productos { get; set; } = new();
        public List<CotizacionImagenUploadDto> Imagenes { get; set; } = new();
    }

    public class SolicitudCotizacionProductoRequestDto
    {
        public int IdProducto { get; set; }
        public int Cantidad { get; set; }
    }

    public class CotizacionImagenUploadDto
    {
        public string NombreOriginal { get; set; } = string.Empty;
        public string TipoContenido { get; set; } = string.Empty;
        public byte[] Contenido { get; set; } = Array.Empty<byte>();
    }
}

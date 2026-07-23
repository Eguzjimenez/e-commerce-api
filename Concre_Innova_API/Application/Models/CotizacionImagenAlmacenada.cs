namespace Concre_Innova_API.Application.Models
{
    public class CotizacionImagenAlmacenada
    {
        public string RutaArchivo { get; set; } = string.Empty;
        public string NombreOriginal { get; set; } = string.Empty;
        public string TipoContenido { get; set; } = string.Empty;
        public long TamanoBytes { get; set; }
    }
}

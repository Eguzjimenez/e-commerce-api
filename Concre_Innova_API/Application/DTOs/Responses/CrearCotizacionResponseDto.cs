namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class CrearCotizacionResponseDto
    {
        public bool Exitoso { get; set; }
        public string Mensaje { get; set; } = string.Empty;
        public int? IdCotizacion { get; set; }
        public string NumeroSeguimiento { get; set; } = string.Empty;
        public int CantidadImagenes { get; set; }
        public List<CotizacionImagenResponseDto> Imagenes { get; set; } = new();
    }

    public class CotizacionImagenResponseDto
    {
        public string RutaArchivo { get; set; } = string.Empty;
        public string NombreOriginal { get; set; } = string.Empty;
        public string TipoContenido { get; set; } = string.Empty;
        public long TamanoBytes { get; set; }
    }
}

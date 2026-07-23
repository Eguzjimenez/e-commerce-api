namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class CotizacionHistorialResponseDto
    {
        public int IdCotizacion { get; set; }
        public string NumeroSeguimiento { get; set; } = string.Empty;
        public int IdCliente { get; set; }
        public string Cliente { get; set; } = string.Empty;
        public DateTime FechaSolicitud { get; set; }
        public string Estado { get; set; } = string.Empty;
        public decimal Total { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public string Preferencias { get; set; } = string.Empty;
        public string Respuesta { get; set; } = string.Empty;
        public DateTime? FechaRespuesta { get; set; }
        public int? IdPedido { get; set; }
        public List<CotizacionProductoResponseDto> Productos { get; set; } = new();
        public List<CotizacionProductoSolicitadoResponseDto> ProductosSolicitados { get; set; } =
            new();
        public List<CotizacionImagenResponseDto> Imagenes { get; set; } = new();
        public List<CotizacionEstadoHistorialResponseDto> HistorialEstados { get; set; } =
            new();
    }

    public class CotizacionProductoResponseDto
    {
        public int IdProducto { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string? Imagen { get; set; }
        public int Cantidad { get; set; }
        public decimal PrecioUnitario { get; set; }
        public decimal Subtotal { get; set; }
    }

    public class CotizacionProductoSolicitadoResponseDto
    {
        public int IdProducto { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string? Imagen { get; set; }
        public int Cantidad { get; set; }
    }

    public class CotizacionEstadoHistorialResponseDto
    {
        public string? EstadoAnterior { get; set; }
        public string EstadoNuevo { get; set; } = string.Empty;
        public DateTime FechaCambio { get; set; }
    }
}

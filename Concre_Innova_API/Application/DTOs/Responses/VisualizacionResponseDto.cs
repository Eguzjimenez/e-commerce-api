namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class VisualizacionResponseDto
    {
        public int IdVisualizacion { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string RutaImagenEspacio { get; set; } = string.Empty;
        public int AnchoLienzo { get; set; }
        public int AltoLienzo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public DateTime FechaActualizacion { get; set; }
        public int TotalProductos { get; set; }
        public List<VisualizacionProductoResponseDto> Productos { get; set; } = new();
    }

    public class VisualizacionProductoResponseDto
    {
        public int IdVisualizacionProducto { get; set; }
        public int IdProducto { get; set; }
        public int? IdVariante { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Imagen { get; set; } = string.Empty;
        public decimal Precio { get; set; }
        public string Tamano { get; set; } = string.Empty;
        public string Material { get; set; } = string.Empty;
        public string Clasificacion { get; set; } = string.Empty;
        public int Cantidad { get; set; }
        public string Color { get; set; } = string.Empty;
        public string Macetero { get; set; } = string.Empty;
        public decimal PosicionX { get; set; }
        public decimal PosicionY { get; set; }
        public decimal Ancho { get; set; }
        public decimal Alto { get; set; }
        public decimal Rotacion { get; set; }
        public int Orden { get; set; }
    }

    public class ImagenEspacioResponseDto
    {
        public bool Exitoso { get; set; }
        public string Mensaje { get; set; } = string.Empty;
        public string RutaImagenEspacio { get; set; } = string.Empty;
    }

    public class GuardarVisualizacionResponseDto
    {
        public bool Exitoso { get; set; }
        public string Mensaje { get; set; } = string.Empty;
        public int? IdVisualizacion { get; set; }
    }
}

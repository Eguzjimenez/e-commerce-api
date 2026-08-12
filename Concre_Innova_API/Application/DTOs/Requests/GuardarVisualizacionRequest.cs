namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class GuardarVisualizacionRequest
    {
        /// <summary>
        /// Nulo cuando se crea una visualizacion nueva.
        /// </summary>
        public int? IdVisualizacion { get; set; }

        public string Nombre { get; set; } = string.Empty;

        /// <summary>
        /// Ruta relativa devuelta al subir la imagen del espacio.
        /// </summary>
        public string RutaImagenEspacio { get; set; } = string.Empty;

        public int AnchoLienzo { get; set; }

        public int AltoLienzo { get; set; }

        public List<VisualizacionProductoRequestDto> Productos { get; set; } = new();
    }

    public class VisualizacionProductoRequestDto
    {
        public int IdProducto { get; set; }
        public int? IdVariante { get; set; }
        public int Cantidad { get; set; } = 1;
        public string Color { get; set; } = string.Empty;
        public string Macetero { get; set; } = string.Empty;
        public decimal PosicionX { get; set; }
        public decimal PosicionY { get; set; }
        public decimal Ancho { get; set; }
        public decimal Alto { get; set; }
        public decimal Rotacion { get; set; }
        public int Orden { get; set; }
    }
}

namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class ActualizarInventarioRequest
    {
        public int IdProducto { get; set; }
        public int CantidadDisponible { get; set; }
        public int CantidadMinima { get; set; }
    }
}

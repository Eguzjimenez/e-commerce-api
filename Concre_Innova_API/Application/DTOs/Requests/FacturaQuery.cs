namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class FacturaQuery
    {
        public string? Busqueda { get; set; }
        public string? Estado { get; set; }
        public DateTime? Desde { get; set; }
        public DateTime? Hasta { get; set; }
    }

    public class ActualizarEstadoFacturaRequest
    {
        public int IdVenta { get; set; }
        public string? EstadoPago { get; set; }
        public string? Observaciones { get; set; }
    }
}

namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class PedidoAdminQuery
    {
        public string? Busqueda { get; set; }
        public string? Estado { get; set; }
        public DateTime? FechaDesde { get; set; }
        public DateTime? FechaHasta { get; set; }
    }
}

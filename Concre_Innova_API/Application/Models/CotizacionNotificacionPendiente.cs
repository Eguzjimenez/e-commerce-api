namespace Concre_Innova_API.Application.Models
{
    public class CotizacionNotificacionPendiente
    {
        public int IdCotizacionNotificacion { get; set; }
        public string CorreoDestino { get; set; } = string.Empty;
        public string NombreCliente { get; set; } = string.Empty;
        public string NumeroSeguimiento { get; set; } = string.Empty;
        public string EstadoAnterior { get; set; } = string.Empty;
        public string EstadoNuevo { get; set; } = string.Empty;
        public DateTime FechaCambio { get; set; }
    }
}

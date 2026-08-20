namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class RegistrarComprobantePagoRequest
    {
        public int IdPedido { get; set; }

        public string Referencia { get; set; } = string.Empty;

        public IFormFile? Comprobante { get; set; }
    }
}

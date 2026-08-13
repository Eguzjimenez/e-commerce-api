namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class InformacionEmpresaResponseDto
    {
        public int IdInformacion { get; set; }
        public string NombreEmpresa { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public string Correo { get; set; } = string.Empty;
        public string Telefono { get; set; } = string.Empty;
        public string WhatsApp { get; set; } = string.Empty;
        public string Direccion { get; set; } = string.Empty;
        public string Horario { get; set; } = string.Empty;
        public string Facebook { get; set; } = string.Empty;
        public string Instagram { get; set; } = string.Empty;
        public string TikTok { get; set; } = string.Empty;
        public DateTime FechaActualizacion { get; set; }
    }
}

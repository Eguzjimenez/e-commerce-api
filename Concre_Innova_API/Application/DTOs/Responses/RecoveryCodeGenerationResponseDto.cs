using System.Text.Json.Serialization;

namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class RecoveryCodeGenerationResponseDto
    {
        public int Codigo { get; set; }
        public string? Mensaje { get; set; }
        public DateTime? ExpiraEn { get; set; }

        [JsonIgnore]
        public string? Correo { get; set; }

        [JsonIgnore]
        public string? CodigoRecuperacion { get; set; }
    }
}

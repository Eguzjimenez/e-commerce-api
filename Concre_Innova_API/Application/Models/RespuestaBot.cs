using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Application.Models
{
    /// <summary>
    /// Resultado de interpretar el mensaje de un usuario con el asistente virtual.
    /// </summary>
    public class RespuestaBot
    {
        public string Texto { get; set; } = string.Empty;

        public string? CodigoIntencion { get; set; }

        /// <summary>
        /// Verdadero cuando ninguna intencion configurada coincidio con el mensaje
        /// o cuando la intencion detectada requiere atencion personalizada.
        /// </summary>
        public bool SugiereEscalamiento { get; set; }

        public List<CatalogoProductoResponseDto> ProductosRecomendados { get; set; } = new();
    }
}

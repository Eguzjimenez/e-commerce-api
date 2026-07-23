using System.ComponentModel.DataAnnotations;

namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class CotizacionHistorialQuery
    {
        [StringLength(100)]
        public string? Busqueda { get; set; }

        [RegularExpression(
            "^(?i:Pendiente|Respondida|Aceptada|Aprobada|Rechazada)$",
            ErrorMessage = "El estado de cotizacion no es valido.")]
        public string? Estado { get; set; }

        public string? NormalizedSearchTerm =>
            NormalizeText(Busqueda);

        public string? NormalizedStatus =>
            NormalizeText(Estado)?.ToLowerInvariant() switch
            {
                "pendiente" => "Pendiente",
                "respondida" => "Respondida",
                "aceptada" => "Aceptada",
                "aprobada" => "Aprobada",
                "rechazada" => "Rechazada",
                _ => null
            };

        private static string? NormalizeText(string? value)
        {
            return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
        }
    }
}

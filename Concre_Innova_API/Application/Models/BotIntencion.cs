namespace Concre_Innova_API.Application.Models
{
    /// <summary>
    /// Intencion configurada del asistente virtual junto con las palabras
    /// clave que la activan.
    /// </summary>
    public class BotIntencion
    {
        public int IdIntencion { get; set; }
        public string Codigo { get; set; } = string.Empty;
        public string Respuesta { get; set; } = string.Empty;
        public bool SugiereProductos { get; set; }
        public bool SugiereEscalamiento { get; set; }
        public List<string> PalabrasClave { get; set; } = new();
    }
}

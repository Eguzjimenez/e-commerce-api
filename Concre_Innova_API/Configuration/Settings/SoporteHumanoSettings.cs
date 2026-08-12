namespace Concre_Innova_API.Configuration.Settings
{
    /// <summary>
    /// Configuracion del canal de soporte humano al que el chat puede escalar
    /// una conversacion cuando el bot no logra resolver la consulta.
    /// </summary>
    public class SoporteHumanoSettings
    {
        public bool Habilitado { get; set; }

        public string ContactoAlternativo { get; set; } = string.Empty;
    }
}

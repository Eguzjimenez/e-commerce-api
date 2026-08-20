namespace Concre_Innova_API.Domain.Constants
{
    /// <summary>
    /// Estados de cobro de una factura. El estado de la lista se deriva del
    /// estado guardado y de la fecha de vencimiento.
    /// </summary>
    public static class FacturaRules
    {
        public const string Pagada = "Pagada";
        public const string Pendiente = "Pendiente";
        public const string EnVerificacion = "En verificacion";
        public const string Anulada = "Anulada";

        public static readonly string[] EstadosPago =
            { Pagada, Pendiente, EnVerificacion, Anulada };

        public static readonly string[] FiltrosEstado =
            { "pagada", "pendiente", "vencida", "revision" };

        public const int MaximoCaracteresObservaciones = 400;

        public static bool EsEstadoPagoValido(string? estado) =>
            !string.IsNullOrWhiteSpace(estado) &&
            EstadosPago.Contains(estado.Trim(), StringComparer.OrdinalIgnoreCase);

        public static bool EsFiltroValido(string? filtro) =>
            !string.IsNullOrWhiteSpace(filtro) &&
            FiltrosEstado.Contains(filtro.Trim().ToLowerInvariant());
    }
}

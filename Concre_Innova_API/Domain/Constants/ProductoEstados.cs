namespace Concre_Innova_API.Domain.Constants
{
    /// <summary>
    /// Valores almacenados en Productos.Estado.
    /// Un producto en <see cref="Borrador"/> es una copia todavia sin publicar:
    /// no aparece en el catalogo publico hasta que se activa.
    /// </summary>
    public static class ProductoEstados
    {
        public const string Activo = "Activo";
        public const string Inactivo = "Inactivo";
        public const string Borrador = "Borrador";

        public static bool EsBorrador(string? estado)
        {
            return string.Equals(estado?.Trim(), Borrador, StringComparison.OrdinalIgnoreCase);
        }
    }
}

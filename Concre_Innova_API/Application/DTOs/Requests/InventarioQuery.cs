namespace Concre_Innova_API.Application.DTOs.Requests
{
    /// <summary>
    /// Filtros del listado de inventario. Se normalizan aqui para que el
    /// repositorio reciba siempre valores listos para el procedimiento.
    /// </summary>
    public class InventarioQuery
    {
        public string? Busqueda { get; set; }
        public int? IdCategoria { get; set; }
        public string? Estado { get; set; }
    }
}

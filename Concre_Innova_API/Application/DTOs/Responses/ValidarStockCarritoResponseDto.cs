namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class ValidarStockCarritoResponseDto
    {
        public List<ValidacionStockItemDto> Items { get; set; } = new();
        public bool TodoDisponible =>
            Items.Count > 0 &&
            Items.All(item =>
                string.Equals(
                    item.Estado,
                    "DISPONIBLE",
                    StringComparison.OrdinalIgnoreCase));
        public decimal Subtotal => Items.Sum(item => item.Subtotal);
    }

    public class ValidacionStockItemDto
    {
        public int IdProducto { get; set; }
        public int? IdVariante { get; set; }
        public string? Nombre { get; set; }
        public int CantidadSolicitada { get; set; }
        public int StockDisponible { get; set; }
        public decimal PrecioUnitario { get; set; }
        public decimal Subtotal { get; set; }
        public string Estado { get; set; } = string.Empty;
    }
}

namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class ValidarStockCarritoResponseDto
    {
        public List<ValidacionStockItemDto> Items { get; set; } = new();
        public bool TodoDisponible => Items.All(i => i.Estado == "DISPONIBLE");
    }

    public class ValidacionStockItemDto
    {
        public int IdProducto { get; set; }
        public string? Nombre { get; set; }
        public int CantidadSolicitada { get; set; }
        public int StockDisponible { get; set; }
        public string Estado { get; set; } = string.Empty;
    }
}

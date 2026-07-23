namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class ValidarStockCarritoRequest
    {
        public List<ItemCarritoRequest> Items { get; set; } = new();
    }

    public class ItemCarritoRequest
    {
        public int IdProducto { get; set; }
        public int? IdVariante { get; set; }
        public string? NombreVariante { get; set; }
        public string? Tamano { get; set; }
        public string? Material { get; set; }
        public string? Color { get; set; }
        public int Cantidad { get; set; }
    }
}

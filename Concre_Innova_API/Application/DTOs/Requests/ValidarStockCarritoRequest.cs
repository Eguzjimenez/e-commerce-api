namespace Concre_Innova_API.Application.DTOs.Requests
{
    public class ValidarStockCarritoRequest
    {
        public List<ItemCarritoRequest> Items { get; set; } = new();
    }

    public class ItemCarritoRequest
    {
        public int IdProducto { get; set; }
        public int Cantidad { get; set; }
    }
}

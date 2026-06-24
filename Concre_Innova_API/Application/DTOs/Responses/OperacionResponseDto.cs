namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class OperacionResponseDto
    {
        public int Codigo { get; set; }
        public string Mensaje { get; set; } = string.Empty;
        public int? IdProducto { get; set; }
    }
}

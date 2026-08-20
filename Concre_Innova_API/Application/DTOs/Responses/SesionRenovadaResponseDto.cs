namespace Concre_Innova_API.Application.DTOs.Responses
{
    /// <summary>
    /// Token nuevo emitido para una sesion que sigue activa.
    /// </summary>
    public class SesionRenovadaResponseDto
    {
        public string Token { get; set; } = string.Empty;
        public int MinutosVigencia { get; set; }
    }
}

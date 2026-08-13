namespace Concre_Innova_API.Application.Models
{
    /// <summary>
    /// Resultado de responder una consulta: incluye los datos de contacto del
    /// cliente para poder enviarle la respuesta por correo.
    /// </summary>
    public class ConsultaRespondida
    {
        public bool Exitoso { get; init; }

        public string Mensaje { get; init; } = string.Empty;

        public string CorreoCliente { get; init; } = string.Empty;

        public string NombreCliente { get; init; } = string.Empty;

        public string Asunto { get; init; } = string.Empty;
    }
}

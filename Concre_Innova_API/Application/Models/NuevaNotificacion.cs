using Concre_Innova_API.Domain.Constants;

namespace Concre_Innova_API.Application.Models
{
    /// <summary>
    /// Datos necesarios para registrar una notificacion en la bandeja de un usuario.
    /// </summary>
    public class NuevaNotificacion
    {
        public int IdUsuario { get; init; }

        public string Tipo { get; init; } = NotificacionTipos.General;

        public string Titulo { get; init; } = string.Empty;

        public string Mensaje { get; init; } = string.Empty;

        public string? Enlace { get; init; }

        public int? Referencia { get; init; }
    }
}

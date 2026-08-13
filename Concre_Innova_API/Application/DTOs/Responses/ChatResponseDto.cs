namespace Concre_Innova_API.Application.DTOs.Responses
{
    public class ChatMensajeResponseDto
    {
        public int IdMensaje { get; set; }
        public int IdChat { get; set; }
        public string Remitente { get; set; } = string.Empty;
        public string Mensaje { get; set; } = string.Empty;
        public DateTime FechaHora { get; set; }
    }

    public class ChatRespuestaBotResponseDto
    {
        public bool Exitoso { get; set; }
        public string Mensaje { get; set; } = string.Empty;
        public int? IdChat { get; set; }
        public string Estado { get; set; } = string.Empty;
        public ChatMensajeResponseDto? MensajeUsuario { get; set; }
        public ChatMensajeResponseDto? MensajeBot { get; set; }
        public List<CatalogoProductoResponseDto> ProductosRecomendados { get; set; } = new();
        public bool SugiereEscalamiento { get; set; }
        public bool SoporteHumanoHabilitado { get; set; }

        /// <summary>
        /// Verdadero cuando la conversacion quedo registrada en la base de datos.
        /// Los visitantes sin sesion reciben respuesta del bot sin persistencia.
        /// </summary>
        public bool ConversacionRegistrada { get; set; }
    }

    public class ChatConversacionResponseDto
    {
        public int? IdChat { get; set; }
        public string Estado { get; set; } = string.Empty;
        public DateTime? FechaInicio { get; set; }
        public DateTime? FechaCierre { get; set; }
        public bool SoporteHumanoHabilitado { get; set; }
        public List<ChatMensajeResponseDto> Mensajes { get; set; } = new();
    }

    public class ChatOperacionResponseDto
    {
        public bool Exitoso { get; set; }
        public string Mensaje { get; set; } = string.Empty;
        public string Estado { get; set; } = string.Empty;
    }

    public class ChatAdminResponseDto
    {
        public int IdChat { get; set; }
        public int IdCliente { get; set; }
        public string Cliente { get; set; } = string.Empty;
        public string CorreoCliente { get; set; } = string.Empty;
        public string Estado { get; set; } = string.Empty;
        public DateTime? FechaInicio { get; set; }
        public DateTime? FechaCierre { get; set; }
        public int? IdUsuarioSoporte { get; set; }
        public string UltimoMensaje { get; set; } = string.Empty;
        public DateTime? FechaUltimoMensaje { get; set; }
        public int TotalMensajes { get; set; }

        /// <summary>
        /// Mensajes del cliente recibidos despues de la ultima respuesta de soporte.
        /// Es el indicador de conversaciones pendientes de atencion.
        /// </summary>
        public int MensajesSinLeer { get; set; }
    }

    /// <summary>
    /// Contadores de la bandeja de atencion mostrados al personal de ventas.
    /// </summary>
    public class ChatAdminResumenResponseDto
    {
        public int Activas { get; set; }
        public int Escaladas { get; set; }
        public int Finalizadas { get; set; }
        public int Pendientes { get; set; }
    }
}

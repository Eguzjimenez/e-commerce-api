using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ChatController : ControllerBase
    {
        private const string MensajeSesionRequerida =
            "Debe iniciar sesion para gestionar su conversacion.";

        private readonly IChatService _chatService;
        private readonly IChatAdminService _chatAdminService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;

        public ChatController(
            IChatService chatService,
            IChatAdminService chatAdminService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService)
        {
            _chatService = chatService;
            _chatAdminService = chatAdminService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
        }

        [HttpPost("mensajes")]
        public async Task<ActionResult<ChatRespuestaBotResponseDto>> EnviarMensaje(
            [FromBody] EnviarMensajeChatRequest request,
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var idUsuario = userContext.IsAuthenticated ? userContext.UserId : null;

            try
            {
                var resultado = await _chatService.EnviarMensajeAsync(
                    idUsuario,
                    request,
                    cancellationToken);

                return resultado.Exitoso ? Ok(resultado) : BadRequest(resultado);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible enviar el mensaje." });
            }
        }

        [Authorize(Roles = AppRoles.RolesCompra)]
        [HttpGet("conversacion")]
        public async Task<ActionResult<ChatConversacionResponseDto>> ObtenerConversacion(
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
                return Unauthorized(new { message = MensajeSesionRequerida });

            try
            {
                var conversacion = await _chatService.ObtenerConversacionAsync(
                    userContext.UserId.Value,
                    cancellationToken);

                return Ok(conversacion);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible cargar la conversacion." });
            }
        }

        [Authorize(Roles = AppRoles.RolesCompra)]
        [HttpPost("escalamiento")]
        public async Task<ActionResult<ChatOperacionResponseDto>> EscalarASoporte(
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
                return Unauthorized(new { message = MensajeSesionRequerida });

            try
            {
                var resultado = await _chatService.EscalarASoporteAsync(
                    userContext.UserId.Value,
                    cancellationToken);

                if (!resultado.Exitoso)
                    return BadRequest(resultado);

                await _auditService.RecordAsync(
                    userContext,
                    "Chats",
                    "UPDATE",
                    "Conversacion de chat escalada a soporte humano.");

                return Ok(resultado);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible escalar la conversacion." });
            }
        }

        [Authorize(Roles = AppRoles.RolesCompra)]
        [HttpPost("finalizacion")]
        public async Task<ActionResult<ChatOperacionResponseDto>> FinalizarConversacion(
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
                return Unauthorized(new { message = MensajeSesionRequerida });

            try
            {
                var resultado = await _chatService.FinalizarConversacionAsync(
                    userContext.UserId.Value,
                    cancellationToken);

                if (!resultado.Exitoso)
                    return BadRequest(resultado);

                await _auditService.RecordAsync(
                    userContext,
                    "Chats",
                    "UPDATE",
                    "Conversacion de chat finalizada por el usuario.");

                return Ok(resultado);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible finalizar la conversacion." });
            }
        }

        [Authorize(Roles = AppRoles.RolesAtencionChat)]
        [HttpGet("admin")]
        public async Task<ActionResult<IEnumerable<ChatAdminResponseDto>>> ObtenerConversaciones(
            [FromQuery] string? estado,
            CancellationToken cancellationToken)
        {
            try
            {
                var conversaciones = await _chatAdminService.ObtenerConversacionesAsync(
                    estado,
                    cancellationToken);

                return Ok(conversaciones);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible cargar las conversaciones." });
            }
        }

        [Authorize(Roles = AppRoles.RolesAtencionChat)]
        [HttpGet("admin/resumen")]
        public async Task<ActionResult<ChatAdminResumenResponseDto>> ObtenerResumenConversaciones(
            CancellationToken cancellationToken)
        {
            try
            {
                var resumen = await _chatAdminService.ObtenerResumenAsync(cancellationToken);
                return Ok(resumen);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible cargar el resumen de conversaciones." });
            }
        }

        [Authorize(Roles = AppRoles.RolesAtencionChat)]
        [HttpGet("admin/{idChat:int}/mensajes")]
        public async Task<ActionResult<IEnumerable<ChatMensajeResponseDto>>> ObtenerMensajes(
            int idChat,
            CancellationToken cancellationToken)
        {
            try
            {
                var mensajes = await _chatAdminService.ObtenerMensajesAsync(
                    idChat,
                    cancellationToken);

                return Ok(mensajes);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible cargar los mensajes." });
            }
        }

        [Authorize(Roles = AppRoles.RolesAtencionChat)]
        [HttpPost("admin/{idChat:int}/mensajes")]
        public async Task<ActionResult<ChatMensajeResponseDto>> Responder(
            int idChat,
            [FromBody] EnviarMensajeChatRequest request,
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            try
            {
                var mensaje = await _chatAdminService.ResponderAsync(
                    idChat,
                    request,
                    cancellationToken);

                if (mensaje is null)
                {
                    return BadRequest(new
                    {
                        message = "No fue posible registrar la respuesta en la conversacion."
                    });
                }

                await _auditService.RecordAsync(
                    userContext,
                    "MensajesChat",
                    "CREATE",
                    $"Respuesta de soporte enviada en el chat #{idChat}.");

                return Ok(mensaje);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible enviar la respuesta." });
            }
        }

        [Authorize(Roles = AppRoles.RolesAtencionChat)]
        [HttpPost("admin/{idChat:int}/cierre")]
        public async Task<ActionResult<ChatOperacionResponseDto>> CerrarConversacion(
            int idChat,
            CancellationToken cancellationToken)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            try
            {
                var resultado = await _chatAdminService.CerrarConversacionAsync(
                    idChat,
                    cancellationToken);

                if (!resultado.Exitoso)
                    return BadRequest(resultado);

                await _auditService.RecordAsync(
                    userContext,
                    "Chats",
                    "UPDATE",
                    $"Conversacion #{idChat} cerrada por el personal de atencion.");

                return Ok(resultado);
            }
            catch (OperationCanceledException)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "No fue posible cerrar la conversacion." });
            }
        }
    }
}

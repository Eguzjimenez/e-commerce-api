using Microsoft.AspNetCore.Mvc;
using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Security;
using Concre_Innova_API.Domain.Constants;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BitacoraController : ControllerBase
    {
        private readonly IBitacoraService _bitacoraService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IPermissionService _permissionService;
        private readonly IAuditService _auditService;

        public BitacoraController(
            IBitacoraService bitacoraService,
            IRequestUserContextService requestUserContextService,
            IPermissionService permissionService,
            IAuditService auditService)
        {
            _bitacoraService = bitacoraService;
            _requestUserContextService = requestUserContextService;
            _permissionService = permissionService;
            _auditService = auditService;
        }

        // GET api/Bitacora/List
        [HttpGet("List")]
        public async Task<IActionResult> GetBitacora(
            [FromQuery] int? pagina = null,
            [FromQuery] int? tamanoPagina = null,
            [FromQuery] string? busqueda = null,
            [FromQuery] string? operacion = null)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.BitacoraVer, "READ");
            if (denied != null)
                return denied;

            var pagination = new PaginationQuery(pagina, tamanoPagina, defaultPageSize: 50);
            if (pagination.IsRequested)
            {
                var pagedList = await _bitacoraService.GetBitacoraPaginadaAsync(
                    pagination,
                    busqueda,
                    operacion);
                return Ok(pagedList);
            }

            var list = await _bitacoraService.GetBitacoraAsync();
            return Ok(list);
        }

        // POST api/Bitacora/acceso-denegado
        // Registra el intento de acceso a una ruta protegida rechazado por la
        // aplicacion web. Solo deja constancia del propio usuario autenticado.
        [HttpPost("acceso-denegado")]
        public async Task<IActionResult> RegistrarAccesoDenegado(
            [FromBody] RegistrarAccesoDenegadoRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated)
                return Unauthorized(new { message = "Debe iniciar sesion para acceder a este recurso." });

            var ruta = request?.Ruta?.Trim();

            if (string.IsNullOrWhiteSpace(ruta) || ruta.Length > 255)
                return BadRequest(new { message = "La ruta reportada no es valida." });

            await _auditService.RecordAsync(
                userContext,
                "Seguridad",
                "DENIED",
                $"Acceso denegado a la ruta protegida {ruta}.");

            return Ok(new { message = "Intento registrado." });
        }

        // POST api/Bitacora/Register
        [HttpPost("Register")]
        public async Task<IActionResult> Register([FromBody] CreateBitacoraRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            if (!userContext.IsAuthenticated)
                return Unauthorized(new { message = "Debe iniciar sesion para registrar auditoria." });

            if (request == null)
                return BadRequest();

            var ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "Desconocida";

            var result = await _bitacoraService.InsertBitacoraAsync(
                request.IdUsuario,
                request.TablaAfectada  ?? string.Empty,
                request.Operacion      ?? string.Empty,
                request.Descripcion    ?? string.Empty,
                ip
            );

            if (result.Codigo == 1)
                return Ok(result);

            return BadRequest(result.Mensaje);
        }

        private async Task<ActionResult?> RequirePermissionAsync(
            RequestUserContext userContext,
            string permissionCode,
            string operation)
        {
            if (!userContext.IsAuthenticated || !userContext.RoleId.HasValue)
                return Unauthorized(new { message = "Debe iniciar sesion para acceder a este recurso." });

            var hasPermission = await _permissionService.RoleHasPermissionAsync(
                userContext.RoleId.Value,
                permissionCode);

            if (hasPermission)
                return null;

            await _auditService.RecordAsync(
                userContext,
                "Bitacora",
                "DENIED",
                $"Intento no autorizado de {operation} con permiso {permissionCode}.");

            return StatusCode(
                StatusCodes.Status403Forbidden,
                new { message = "No tiene permisos para realizar esta accion." });
        }
    }
}

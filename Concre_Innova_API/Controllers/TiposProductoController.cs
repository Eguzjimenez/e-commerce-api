using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Interfaces.Validators;
using Concre_Innova_API.Application.Security;
using Concre_Innova_API.Domain.Constants;
using Microsoft.AspNetCore.Mvc;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TiposProductoController : ControllerBase
    {
        private readonly ICatalogoService _catalogoService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;
        private readonly ITipoProductoRequestValidator _tipoProductoRequestValidator;
        private readonly IPermissionService _permissionService;

        public TiposProductoController(
            ICatalogoService catalogoService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService,
            ITipoProductoRequestValidator tipoProductoRequestValidator,
            IPermissionService permissionService)
        {
            _catalogoService = catalogoService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
            _tipoProductoRequestValidator = tipoProductoRequestValidator;
            _permissionService = permissionService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<TipoProductoResponseDto>>> ObtenerTiposProducto()
        {
            try
            {
                var tipos = await _catalogoService.ObtenerTiposProductoAsync();
                return Ok(tipos);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener los tipos de producto.", error = ex.Message });
            }
        }

        [HttpGet("administracion")]
        public async Task<ActionResult<IEnumerable<TipoProductoResponseDto>>> ObtenerTiposProductoAdministracion()
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.TiposProductoLeer, "READ");
            if (denied != null)
                return denied;

            try
            {
                var tipos = await _catalogoService.ObtenerTiposProductoAdministracionAsync();
                return Ok(tipos);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener los tipos de producto.", error = ex.Message });
            }
        }

        [HttpPost]
        public async Task<ActionResult<TipoProductoOperacionResponseDto>> InsertarTipoProducto(
            [FromBody] CreateTipoProductoRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.TiposProductoCrear, "CREATE");
            if (denied != null)
                return denied;

            var validationMessage = _tipoProductoRequestValidator.ValidateCreate(request);
            if (validationMessage is not null)
                return BadRequest(new { message = validationMessage });

            await _auditService.RecordAsync(
                userContext,
                "TiposProducto",
                "CREATE",
                $"Intento de insertar tipo de producto: {request.NombreTipo}");

            try
            {
                var result = await _catalogoService.InsertarTipoProductoAsync(request);

                if (result.Codigo == 1)
                {
                    await _auditService.RecordAsync(
                        userContext,
                        "TiposProducto",
                        "SUCCESS",
                        $"Tipo de producto '{request.NombreTipo}' insertado exitosamente. ID: {result.IdTipo}");

                    return Ok(result);
                }

                await _auditService.RecordAsync(
                    userContext,
                    "TiposProducto",
                    "FAILED",
                    $"Error al insertar tipo de producto: {result.Mensaje}");

                return BadRequest(result);
            }
            catch (Exception ex)
            {
                await _auditService.RecordAsync(
                    userContext,
                    "TiposProducto",
                    "ERROR",
                    $"Excepcion al insertar tipo de producto: {ex.Message}");

                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al insertar el tipo de producto.", error = ex.Message });
            }
        }

        [HttpPut("{idTipo:int}")]
        public async Task<ActionResult<TipoProductoOperacionResponseDto>> ActualizarTipoProducto(
            int idTipo,
            [FromBody] UpdateTipoProductoRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.TiposProductoActualizar, "UPDATE");
            if (denied != null)
                return denied;

            var validationMessage = _tipoProductoRequestValidator.ValidateUpdate(request);
            if (validationMessage is not null)
                return BadRequest(new { message = validationMessage });

            if (idTipo != request.IdTipo)
            {
                return BadRequest(new { message = "El ID del tipo de producto en la URL no coincide con el del cuerpo de la solicitud." });
            }

            await _auditService.RecordAsync(
                userContext,
                "TiposProducto",
                "UPDATE",
                $"Intento de actualizar tipo de producto ID: {idTipo}");

            try
            {
                var result = await _catalogoService.ActualizarTipoProductoAsync(request);

                if (result.Codigo == 1)
                {
                    await _auditService.RecordAsync(
                        userContext,
                        "TiposProducto",
                        "SUCCESS",
                        $"Tipo de producto ID: {idTipo} actualizado exitosamente.");

                    return Ok(result);
                }

                await _auditService.RecordAsync(
                    userContext,
                    "TiposProducto",
                    "FAILED",
                    $"Error al actualizar tipo de producto ID: {idTipo}. {result.Mensaje}");

                return BadRequest(result);
            }
            catch (Exception ex)
            {
                await _auditService.RecordAsync(
                    userContext,
                    "TiposProducto",
                    "ERROR",
                    $"Excepcion al actualizar tipo de producto ID: {idTipo}. {ex.Message}");

                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al actualizar el tipo de producto.", error = ex.Message });
            }
        }

        [HttpDelete("{idTipo:int}")]
        public async Task<ActionResult<TipoProductoOperacionResponseDto>> EliminarTipoProducto(int idTipo)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.TiposProductoEliminar, "DELETE");
            if (denied != null)
                return denied;

            await _auditService.RecordAsync(
                userContext,
                "TiposProducto",
                "DELETE",
                $"Intento de eliminar tipo de producto ID: {idTipo}");

            try
            {
                var result = await _catalogoService.EliminarTipoProductoAsync(idTipo);

                if (result.Codigo == 1)
                {
                    await _auditService.RecordAsync(
                        userContext,
                        "TiposProducto",
                        "SUCCESS",
                        $"Tipo de producto ID: {idTipo} desactivado exitosamente.");

                    return Ok(result);
                }

                await _auditService.RecordAsync(
                    userContext,
                    "TiposProducto",
                    "FAILED",
                    $"Error al eliminar tipo de producto ID: {idTipo}. {result.Mensaje}");

                return BadRequest(result);
            }
            catch (Exception ex)
            {
                await _auditService.RecordAsync(
                    userContext,
                    "TiposProducto",
                    "ERROR",
                    $"Excepcion al eliminar tipo de producto ID: {idTipo}. {ex.Message}");

                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al eliminar el tipo de producto.", error = ex.Message });
            }
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
                "TiposProducto",
                "DENIED",
                $"Intento no autorizado de {operation} con permiso {permissionCode}.");

            return StatusCode(
                StatusCodes.Status403Forbidden,
                new { message = "No tiene permisos para realizar esta accion." });
        }
    }
}

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
    public class CategoriasController : ControllerBase
    {
        private readonly ICatalogoService _catalogoService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;
        private readonly ICategoriaRequestValidator _categoriaRequestValidator;
        private readonly IPermissionService _permissionService;

        public CategoriasController(
            ICatalogoService catalogoService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService,
            ICategoriaRequestValidator categoriaRequestValidator,
            IPermissionService permissionService)
        {
            _catalogoService = catalogoService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
            _categoriaRequestValidator = categoriaRequestValidator;
            _permissionService = permissionService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<CategoriaResponseDto>>> ObtenerCategorias()
        {
            try
            {
                var categorias = await _catalogoService.ObtenerCategoriasAsync();
                return Ok(categorias);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener las categorias." });
            }
        }

        [HttpGet("administracion")]
        public async Task<ActionResult<IEnumerable<CategoriaResponseDto>>> ObtenerCategoriasAdministracion()
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.CategoriasLeer, "READ");
            if (denied != null)
                return denied;

            try
            {
                var categorias = await _catalogoService.ObtenerCategoriasAdministracionAsync();
                return Ok(categorias);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener las categorias." });
            }
        }

        [HttpPost]
        public async Task<ActionResult<CategoriaOperacionResponseDto>> InsertarCategoria(
            [FromBody] CreateCategoriaRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.CategoriasCrear, "CREATE");
            if (denied != null)
                return denied;

            var validationMessage = _categoriaRequestValidator.ValidateCreate(request);
            if (validationMessage is not null)
                return BadRequest(new { message = validationMessage });

            await _auditService.RecordAsync(
                userContext,
                "Categorias",
                "CREATE",
                $"Intento de insertar categoria: {request.NombreCategoria}");

            try
            {
                var result = await _catalogoService.InsertarCategoriaAsync(request);

                if (result.Codigo == 1)
                {
                    await _auditService.RecordAsync(
                        userContext,
                        "Categorias",
                        "SUCCESS",
                        $"Categoria '{request.NombreCategoria}' insertada exitosamente. ID: {result.IdCategoria}");

                    return Ok(result);
                }

                await _auditService.RecordAsync(
                    userContext,
                    "Categorias",
                    "FAILED",
                    $"Error al insertar categoria: {result.Mensaje}");

                return BadRequest(result);
            }
            catch (Exception ex)
            {
                await _auditService.RecordAsync(
                    userContext,
                    "Categorias",
                    "ERROR",
                    $"Excepcion al insertar categoria: {ex.Message}");

                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al insertar la categoria." });
            }
        }

        [HttpPut("{idCategoria:int}")]
        public async Task<ActionResult<CategoriaOperacionResponseDto>> ActualizarCategoria(
            int idCategoria,
            [FromBody] UpdateCategoriaRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.CategoriasActualizar, "UPDATE");
            if (denied != null)
                return denied;

            var validationMessage = _categoriaRequestValidator.ValidateUpdate(request);
            if (validationMessage is not null)
                return BadRequest(new { message = validationMessage });

            if (idCategoria != request.IdCategoria)
            {
                return BadRequest(new { message = "El ID de la categoria en la URL no coincide con el del cuerpo de la solicitud." });
            }

            await _auditService.RecordAsync(
                userContext,
                "Categorias",
                "UPDATE",
                $"Intento de actualizar categoria ID: {idCategoria}");

            try
            {
                var result = await _catalogoService.ActualizarCategoriaAsync(request);

                if (result.Codigo == 1)
                {
                    await _auditService.RecordAsync(
                        userContext,
                        "Categorias",
                        "SUCCESS",
                        $"Categoria ID: {idCategoria} actualizada exitosamente.");

                    return Ok(result);
                }

                await _auditService.RecordAsync(
                    userContext,
                    "Categorias",
                    "FAILED",
                    $"Error al actualizar categoria ID: {idCategoria}. {result.Mensaje}");

                return BadRequest(result);
            }
            catch (Exception ex)
            {
                await _auditService.RecordAsync(
                    userContext,
                    "Categorias",
                    "ERROR",
                    $"Excepcion al actualizar categoria ID: {idCategoria}. {ex.Message}");

                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al actualizar la categoria." });
            }
        }

        [HttpDelete("{idCategoria:int}")]
        public async Task<ActionResult<CategoriaOperacionResponseDto>> EliminarCategoria(int idCategoria)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.CategoriasEliminar, "DELETE");
            if (denied != null)
                return denied;

            await _auditService.RecordAsync(
                userContext,
                "Categorias",
                "DELETE",
                $"Intento de eliminar categoria ID: {idCategoria}");

            try
            {
                var result = await _catalogoService.EliminarCategoriaAsync(idCategoria);

                if (result.Codigo == 1)
                {
                    await _auditService.RecordAsync(
                        userContext,
                        "Categorias",
                        "SUCCESS",
                        $"Categoria ID: {idCategoria} desactivada exitosamente.");

                    return Ok(result);
                }

                await _auditService.RecordAsync(
                    userContext,
                    "Categorias",
                    "FAILED",
                    $"Error al eliminar categoria ID: {idCategoria}. {result.Mensaje}");

                return BadRequest(result);
            }
            catch (Exception ex)
            {
                await _auditService.RecordAsync(
                    userContext,
                    "Categorias",
                    "ERROR",
                    $"Excepcion al eliminar categoria ID: {idCategoria}. {ex.Message}");

                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al eliminar la categoria." });
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
                "Categorias",
                "DENIED",
                $"Intento no autorizado de {operation} con permiso {permissionCode}.");

            return StatusCode(
                StatusCodes.Status403Forbidden,
                new { message = "No tiene permisos para realizar esta accion." });
        }
    }
}

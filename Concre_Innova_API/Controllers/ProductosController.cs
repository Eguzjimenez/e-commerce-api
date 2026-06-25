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
    public class ProductosController : ControllerBase
    {
        private readonly ICatalogoService _catalogoService;
        private readonly IRequestUserContextService _requestUserContextService;
        private readonly IAuditService _auditService;
        private readonly IProductoRequestValidator _productoRequestValidator;

        public ProductosController(
            ICatalogoService catalogoService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService,
            IProductoRequestValidator productoRequestValidator)
        {
            _catalogoService = catalogoService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
            _productoRequestValidator = productoRequestValidator;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<CatalogoProductoResponseDto>>> ObtenerCatalogoProductos(
            [FromQuery] string? busqueda = null,
            [FromQuery] string? ordenarPor = null,
            [FromQuery] string? direccionOrden = null,
            [FromQuery] int? idCategoria = null,
            [FromQuery] decimal? precioMinimo = null,
            [FromQuery] decimal? precioMaximo = null,
            [FromQuery] string? disponibilidad = null,
            [FromQuery] string? tamano = null,
            [FromQuery] string? material = null,
            [FromQuery] string? tipo = null)
        {
            try
            {
                var query = new CatalogoProductoQuery
                {
                    Busqueda = busqueda,
                    OrdenarPor = ordenarPor,
                    DireccionOrden = direccionOrden,
                    IdCategoria = idCategoria,
                    PrecioMinimo = precioMinimo,
                    PrecioMaximo = precioMaximo,
                    Disponibilidad = disponibilidad,
                    Tamano = tamano,
                    Material = material,
                    Tipo = tipo
                };

                var productos = await _catalogoService.ObtenerCatalogoProductosAsync(query);
                return Ok(productos);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener el catalogo de productos.", error = ex.Message });
            }
        }

        [HttpGet("{idProducto:int}")]
        public async Task<ActionResult<CatalogoProductoResponseDto>> ObtenerProductoPorId(int idProducto)
        {
            try
            {
                var producto = await _catalogoService.ObtenerProductoPorIdAsync(idProducto);

                if (producto is null)
                    return NotFound(new { message = "Producto no encontrado." });

                return Ok(producto);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener el detalle del producto.", error = ex.Message });
            }
        }

        [HttpPost]
        public async Task<ActionResult<OperacionResponseDto>> InsertarProducto([FromBody] CreateProductoRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequireAdminAsync(userContext, "Productos", "CREATE");
            if (denied != null)
                return denied;

            var validationMessage = _productoRequestValidator.ValidateCreate(request);
            if (validationMessage is not null)
                return BadRequest(new { message = validationMessage });

            await _auditService.RecordAsync(
                userContext,
                "Productos",
                "CREATE",
                $"Intento de insertar producto: {request.Nombre}");

            try
            {
                var result = await _catalogoService.InsertarProductoAsync(request);

                if (result.Codigo == 1)
                {
                    await _auditService.RecordAsync(
                        userContext,
                        "Productos",
                        "SUCCESS",
                        $"Producto '{request.Nombre}' insertado exitosamente. ID: {result.IdProducto}");

                    return Ok(result);
                }

                await _auditService.RecordAsync(
                    userContext,
                    "Productos",
                    "FAILED",
                    $"Error al insertar producto: {result.Mensaje}");

                return BadRequest(result);
            }
            catch (Exception ex)
            {
                await _auditService.RecordAsync(
                    userContext,
                    "Productos",
                    "ERROR",
                    $"Excepcion al insertar producto: {ex.Message}");

                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al insertar el producto.", error = ex.Message });
            }
        }

        [HttpPut("{idProducto:int}")]
        public async Task<ActionResult<OperacionResponseDto>> ActualizarProducto(
            int idProducto,
            [FromBody] UpdateProductoRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequireAdminAsync(userContext, "Productos", "UPDATE");
            if (denied != null)
                return denied;

            var validationMessage = _productoRequestValidator.ValidateUpdate(request);
            if (validationMessage is not null)
                return BadRequest(new { message = validationMessage });

            if (idProducto != request.IdProducto)
            {
                return BadRequest(new { message = "El ID del producto en la URL no coincide con el del cuerpo de la solicitud." });
            }

            await _auditService.RecordAsync(
                userContext,
                "Productos",
                "UPDATE",
                $"Intento de actualizar producto ID: {idProducto}");

            try
            {
                var result = await _catalogoService.ActualizarProductoAsync(request);

                if (result.Codigo == 1)
                {
                    await _auditService.RecordAsync(
                        userContext,
                        "Productos",
                        "SUCCESS",
                        $"Producto ID: {idProducto} actualizado exitosamente.");

                    return Ok(result);
                }

                await _auditService.RecordAsync(
                    userContext,
                    "Productos",
                    "FAILED",
                    $"Error al actualizar producto ID: {idProducto}. {result.Mensaje}");

                return BadRequest(result);
            }
            catch (Exception ex)
            {
                await _auditService.RecordAsync(
                    userContext,
                    "Productos",
                    "ERROR",
                    $"Excepcion al actualizar producto ID: {idProducto}. {ex.Message}");

                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al actualizar el producto.", error = ex.Message });
            }
        }

        [HttpDelete("{idProducto:int}")]
        public async Task<ActionResult<OperacionResponseDto>> EliminarProducto(int idProducto)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequireAdminAsync(userContext, "Productos", "DELETE");
            if (denied != null)
                return denied;

            await _auditService.RecordAsync(
                userContext,
                "Productos",
                "DELETE",
                $"Intento de eliminar producto ID: {idProducto}");

            try
            {
                var result = await _catalogoService.EliminarProductoAsync(idProducto);

                if (result.Codigo == 1)
                {
                    await _auditService.RecordAsync(
                        userContext,
                        "Productos",
                        "SUCCESS",
                        $"Producto ID: {idProducto} desactivado exitosamente.");

                    return Ok(result);
                }

                await _auditService.RecordAsync(
                    userContext,
                    "Productos",
                    "FAILED",
                    $"Error al eliminar producto ID: {idProducto}. {result.Mensaje}");

                return BadRequest(result);
            }
            catch (Exception ex)
            {
                await _auditService.RecordAsync(
                    userContext,
                    "Productos",
                    "ERROR",
                    $"Excepcion al eliminar producto ID: {idProducto}. {ex.Message}");

                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al eliminar el producto.", error = ex.Message });
            }
        }

        private async Task<ActionResult?> RequireAdminAsync(
            RequestUserContext userContext,
            string module,
            string operation)
        {
            if (!userContext.IsAuthenticated)
                return Unauthorized(new { message = "Debe iniciar sesion para acceder a este recurso." });

            if (userContext.RoleId != AppRoles.Administrador)
            {
                await _auditService.RecordAsync(
                    userContext,
                    module,
                    "DENIED",
                    $"Intento no autorizado de {operation}.");

                return StatusCode(
                    StatusCodes.Status403Forbidden,
                    new { message = "No tiene permisos para realizar esta accion." });
            }

            return null;
        }
    }
}

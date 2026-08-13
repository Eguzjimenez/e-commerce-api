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
        private readonly IPermissionService _permissionService;

        public ProductosController(
            ICatalogoService catalogoService,
            IRequestUserContextService requestUserContextService,
            IAuditService auditService,
            IProductoRequestValidator productoRequestValidator,
            IPermissionService permissionService)
        {
            _catalogoService = catalogoService;
            _requestUserContextService = requestUserContextService;
            _auditService = auditService;
            _productoRequestValidator = productoRequestValidator;
            _permissionService = permissionService;
        }

        [HttpGet]
        public async Task<ActionResult> ObtenerCatalogoProductos(
            [FromQuery] string? busqueda = null,
            [FromQuery] string? ordenarPor = null,
            [FromQuery] string? direccionOrden = null,
            [FromQuery] int? idCategoria = null,
            [FromQuery] int? idTipo = null,
            [FromQuery] decimal? precioMinimo = null,
            [FromQuery] decimal? precioMaximo = null,
            [FromQuery] string? disponibilidad = null,
            [FromQuery] string? tamano = null,
            [FromQuery] string? material = null,
            [FromQuery] string? tipo = null,
            [FromQuery] int? pagina = null,
            [FromQuery] int? tamanoPagina = null,
            [FromQuery] bool incluirBorradores = false)
        {
            var mostrarBorradores = incluirBorradores &&
                await TienePermisoAsync(PermissionCodes.ProductosDuplicar);

            try
            {
                var query = new CatalogoProductoQuery
                {
                    IncluirBorradores = mostrarBorradores,
                    Busqueda = busqueda,
                    OrdenarPor = ordenarPor,
                    DireccionOrden = direccionOrden,
                    IdCategoria = idCategoria,
                    IdTipo = idTipo,
                    PrecioMinimo = precioMinimo,
                    PrecioMaximo = precioMaximo,
                    Disponibilidad = disponibilidad,
                    Tamano = tamano,
                    Material = material,
                    Tipo = tipo
                };

                var pagination = new PaginationQuery(pagina, tamanoPagina, defaultPageSize: 12);
                if (pagination.IsRequested)
                {
                    var pagedProducts = await _catalogoService.ObtenerCatalogoProductosPaginadoAsync(
                        query,
                        pagination);
                    return Ok(pagedProducts);
                }

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

        [HttpGet("filtros")]
        public async Task<ActionResult<CatalogoFiltrosResponseDto>> ObtenerFiltrosCatalogo()
        {
            try
            {
                var filtros = await _catalogoService.ObtenerFiltrosCatalogoAsync();
                return Ok(filtros);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener los filtros del catalogo.", error = ex.Message });
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

        [HttpGet("{idProducto:int}/relacionados")]
        public async Task<ActionResult<IEnumerable<CatalogoProductoResponseDto>>> ObtenerProductosRelacionados(
            int idProducto,
            [FromQuery] int limite = 4)
        {
            try
            {
                var productos = await _catalogoService.ObtenerProductosRelacionadosAsync(idProducto, limite);
                return Ok(productos);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener los productos relacionados.", error = ex.Message });
            }
        }

        [HttpGet("{idProducto:int}/variantes")]
        public async Task<ActionResult<IEnumerable<ProductoVarianteResponseDto>>> ObtenerProductoVariantes(
            int idProducto)
        {
            try
            {
                var variantes = await _catalogoService.ObtenerProductoVariantesAsync(idProducto);
                return Ok(variantes);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener las variantes del producto.", error = ex.Message });
            }
        }

        [HttpPost("upload-image")]
        public async Task<IActionResult> UploadProductImage(IFormFile file)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.ProductosCrear, "UPLOAD_IMAGE");
            if (denied != null)
                return denied;

            if (file == null || file.Length == 0)
                return BadRequest(new { message = "La imagen del producto es requerida." });

            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            var allowedExtensions = new HashSet<string> { ".jpg", ".jpeg", ".png", ".webp", ".gif" };

            if (!allowedExtensions.Contains(extension))
                return BadRequest(new { message = "Formato de imagen no permitido." });

            var uploadsFolder = Path.Combine(
                Directory.GetCurrentDirectory(),
                "wwwroot",
                "images",
                "productos");

            Directory.CreateDirectory(uploadsFolder);

            var fileName = $"{Guid.NewGuid():N}{extension}";
            var physicalPath = Path.Combine(uploadsFolder, fileName);

            await using (var stream = System.IO.File.Create(physicalPath))
            {
                await file.CopyToAsync(stream);
            }

            var relativePath = $"images/productos/{fileName}";
            return Ok(new { ruta = relativePath, imagen = relativePath });
        }

        [HttpPost]
        public async Task<ActionResult<OperacionResponseDto>> InsertarProducto([FromBody] CreateProductoRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.ProductosCrear, "CREATE");
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

        [HttpPost("{idProducto:int}/duplicado")]
        public async Task<ActionResult<OperacionResponseDto>> DuplicarProducto(int idProducto)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequirePermissionAsync(
                userContext,
                PermissionCodes.ProductosDuplicar,
                "DUPLICATE");

            if (denied != null)
                return denied;

            try
            {
                var result = await _catalogoService.DuplicarProductoAsync(
                    idProducto,
                    userContext.UserId);

                if (result.Codigo != 1)
                {
                    await _auditService.RecordAsync(
                        userContext,
                        "Productos",
                        "FAILED",
                        $"Error al duplicar producto ID: {idProducto}. {result.Mensaje}");

                    return BadRequest(result);
                }

                await _auditService.RecordAsync(
                    userContext,
                    "Productos",
                    "SUCCESS",
                    $"Producto ID: {idProducto} duplicado como borrador ID: {result.IdProducto}.");

                return Ok(result);
            }
            catch (Exception ex)
            {
                await _auditService.RecordAsync(
                    userContext,
                    "Productos",
                    "ERROR",
                    $"Excepcion al duplicar producto ID: {idProducto}. {ex.Message}");

                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al duplicar el producto.", error = ex.Message });
            }
        }

        [HttpPut("{idProducto:int}")]
        public async Task<ActionResult<OperacionResponseDto>> ActualizarProducto(
            int idProducto,
            [FromBody] UpdateProductoRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            var denied = await RequireProductUpdatePermissionAsync(userContext, idProducto, request);
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
            var denied = await RequirePermissionAsync(userContext, PermissionCodes.ProductosEliminar, "DELETE");
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

        /// <summary>
        /// Autoriza la actualizacion de un producto. Quien administra el catalogo
        /// puede editar cualquier producto; quien solo tiene permiso de duplicacion
        /// puede ajustar la copia mientras siga siendo un borrador, pero no publicarla.
        /// </summary>
        private async Task<ActionResult?> RequireProductUpdatePermissionAsync(
            RequestUserContext userContext,
            int idProducto,
            UpdateProductoRequest request)
        {
            if (!userContext.IsAuthenticated || !userContext.RoleId.HasValue)
                return Unauthorized(new { message = "Debe iniciar sesion para acceder a este recurso." });

            if (await TienePermisoAsync(PermissionCodes.ProductosActualizar))
                return null;

            if (await PuedeAjustarBorradorAsync(idProducto, request))
                return null;

            await _auditService.RecordAsync(
                userContext,
                "Productos",
                "DENIED",
                $"Intento no autorizado de UPDATE con permiso {PermissionCodes.ProductosActualizar}.");

            return StatusCode(
                StatusCodes.Status403Forbidden,
                new { message = "No tiene permisos para realizar esta accion." });
        }

        private async Task<bool> PuedeAjustarBorradorAsync(
            int idProducto,
            UpdateProductoRequest request)
        {
            if (!await TienePermisoAsync(PermissionCodes.ProductosDuplicar))
                return false;

            if (!ProductoEstados.EsBorrador(request?.Estado))
                return false;

            return await _catalogoService.EsProductoBorradorAsync(idProducto);
        }

        private async Task<bool> TienePermisoAsync(string permissionCode)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.RoleId.HasValue)
                return false;

            return await _permissionService.RoleHasPermissionAsync(
                userContext.RoleId.Value,
                permissionCode);
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
                "Productos",
                "DENIED",
                $"Intento no autorizado de {operation} con permiso {permissionCode}.");

            return StatusCode(
                StatusCodes.Status403Forbidden,
                new { message = "No tiene permisos para realizar esta accion." });
        }
    }
}

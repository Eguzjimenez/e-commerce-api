using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class FavoritosController : ControllerBase
    {
        private readonly IFavoriteService _favoriteService;
        private readonly IRequestUserContextService _requestUserContextService;

        public FavoritosController(
            IFavoriteService favoriteService,
            IRequestUserContextService requestUserContextService)
        {
            _favoriteService = favoriteService;
            _requestUserContextService = requestUserContextService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<CatalogoProductoResponseDto>>> GetFavorites()
        {
            var userId = GetAuthenticatedUserId();
            if (!userId.HasValue)
                return Unauthorized(new { message = "Debe iniciar sesion para consultar favoritos." });

            var favorites = await _favoriteService.GetFavoritesAsync(userId.Value);
            return Ok(favorites);
        }

        [HttpGet("count")]
        public async Task<ActionResult<object>> GetFavoriteCount()
        {
            var userId = GetAuthenticatedUserId();
            if (!userId.HasValue)
                return Unauthorized(new { message = "Debe iniciar sesion para consultar favoritos." });

            var count = await _favoriteService.GetFavoriteCountAsync(userId.Value);
            return Ok(new { count });
        }

        [HttpGet("ids")]
        public async Task<ActionResult<IEnumerable<int>>> GetFavoriteProductIds()
        {
            var userId = GetAuthenticatedUserId();
            if (!userId.HasValue)
                return Unauthorized(new { message = "Debe iniciar sesion para consultar favoritos." });

            var favoriteIds = await _favoriteService.GetFavoriteProductIdsAsync(userId.Value);
            return Ok(favoriteIds);
        }

        [HttpPost("{idProducto:int}")]
        public async Task<ActionResult<OperacionResponseDto>> AddFavorite(int idProducto)
        {
            var userId = GetAuthenticatedUserId();
            if (!userId.HasValue)
                return Unauthorized(new { message = "Debe iniciar sesion para agregar favoritos." });

            if (idProducto <= 0)
                return BadRequest(new { message = "El producto es requerido." });

            var result = await _favoriteService.AddFavoriteAsync(userId.Value, idProducto);
            return result.Codigo == 1 ? Ok(result) : BadRequest(result);
        }

        [HttpDelete("{idProducto:int}")]
        public async Task<ActionResult<OperacionResponseDto>> RemoveFavorite(int idProducto)
        {
            var userId = GetAuthenticatedUserId();
            if (!userId.HasValue)
                return Unauthorized(new { message = "Debe iniciar sesion para eliminar favoritos." });

            if (idProducto <= 0)
                return BadRequest(new { message = "El producto es requerido." });

            var result = await _favoriteService.RemoveFavoriteAsync(userId.Value, idProducto);
            return Ok(result);
        }

        private int? GetAuthenticatedUserId()
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);
            return userContext.IsAuthenticated ? userContext.UserId : null;
        }
    }
}

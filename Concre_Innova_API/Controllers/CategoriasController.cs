using Microsoft.AspNetCore.Mvc;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.DTOs.Responses;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CategoriasController : ControllerBase
    {
        private readonly ICatalogoService _catalogoService;

        public CategoriasController(ICatalogoService catalogoService)
        {
            _catalogoService = catalogoService;
        }

        /// <summary>
        /// Obtiene el catálogo de categorías activas
        /// </summary>
        /// <returns>Lista de categorías activas</returns>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<CategoriaResponseDto>>> ObtenerCategorias()
        {
            try
            {
                var categorias = await _catalogoService.ObtenerCategoriasAsync();
                return Ok(categorias);
            }
            catch (Exception ex)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener las categorías.", error = ex.Message });
            }
        }
    }
}

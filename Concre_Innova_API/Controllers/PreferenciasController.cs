using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PreferenciasController : ControllerBase
    {
        private readonly IPreferenciasService _preferenciasService;
        private readonly IRequestUserContextService _requestUserContextService;

        public PreferenciasController(
            IPreferenciasService preferenciasService,
            IRequestUserContextService requestUserContextService)
        {
            _preferenciasService = preferenciasService;
            _requestUserContextService = requestUserContextService;
        }

        [HttpGet]
        public async Task<ActionResult> ObtenerPreferencias()
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
                return Unauthorized(new { message = "Debe iniciar sesion para consultar sus preferencias." });

            try
            {
                var preferencias = await _preferenciasService.ObtenerAsync(userContext.UserId.Value);
                return Ok(preferencias);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al obtener las preferencias." });
            }
        }

        [HttpPut]
        public async Task<ActionResult> ActualizarPreferencias(
            [FromBody] ActualizarPreferenciasRequest request)
        {
            var userContext = _requestUserContextService.GetCurrentUser(HttpContext);

            if (!userContext.IsAuthenticated || !userContext.UserId.HasValue)
                return Unauthorized(new { message = "Debe iniciar sesion para actualizar sus preferencias." });

            try
            {
                var resultado = await _preferenciasService.ActualizarAsync(
                    userContext.UserId.Value,
                    request);

                if (resultado.Codigo == 1)
                    return Ok(resultado);

                return BadRequest(resultado);
            }
            catch (Exception)
            {
                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { message = "Error al actualizar las preferencias." });
            }
        }
    }
}

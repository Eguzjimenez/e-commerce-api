using Microsoft.AspNetCore.Mvc;
using Concre_Innova_API.Models.DTOs.Requests;
using Concre_Innova_API.Services.Bitacora;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BitacoraController : ControllerBase
    {
        private readonly IBitacoraService _bitacoraService;

        public BitacoraController(IBitacoraService bitacoraService)
        {
            _bitacoraService = bitacoraService;
        }

        // GET api/Bitacora/List
        [HttpGet("List")]
        public async Task<IActionResult> GetBitacora()
        {
            var list = await _bitacoraService.GetBitacoraAsync();
            return Ok(list);
        }

        // POST api/Bitacora/Register
        [HttpPost("Register")]
        public async Task<IActionResult> Register([FromBody] CreateBitacoraRequest request)
        {
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
    }
}

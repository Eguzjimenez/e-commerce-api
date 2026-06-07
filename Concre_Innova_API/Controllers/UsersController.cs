using Microsoft.AspNetCore.Mvc;
using Concre_Innova_API.Repositories.Users;
using System.Collections.Generic;
using Concre_Innova_API.Models.DTOs.Responses;
using Concre_Innova_API.Services;
using Concre_Innova_API.Models.DTOs.Requests;
using Concre_Innova_API.Models.Entities;

namespace Concre_Innova_API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpPut("UpdateUser")]
    public async Task<ActionResult> UpdateUser([FromBody] UpdateUserRequest request)
    {
        if (request == null)
            return BadRequest();

        var user = new User
        {
            IdUsuario = request.IdUsuario,
            Nombre = request.Nombre,
            Apellido = request.Apellido,
            Correo = request.Correo,
            Contrasena = request.Contrasena,
            Telefono = request.Telefono,
            IdRol = request.IdRol
        };

        var result = await _userService.UpdateUserAsync(user);

        if (result == null)
            return StatusCode(500, "Error updating user");

        if (result.Codigo == 1)
            return Ok(result.Mensaje);

        return BadRequest(result.Mensaje);
    }

    [HttpGet("UserList")]
    public async Task<ActionResult<IEnumerable<UserResponseDto>>> UserList()
    {
        var users = await _userService.GetUsersAsync();
        return Ok(users);
    }

    [HttpPost("NewUser")]
    public async Task<ActionResult<User>> NewUser([FromBody] CreateUserRequest request)
    {
        if (request == null)
            return BadRequest();

        var user = new User
        {
            Nombre = request.Nombre,
            Apellido = request.Apellido,
            Correo = request.Correo,
            Contrasena = request.Contrasena,
            Telefono = request.Telefono,
            IdRol = request.IdRol
        };

        var result = await _userService.InsertUserAsync(user);

        if (result == null)
            return StatusCode(500, "Error creating user");

        if (result.Codigo == 1)
            return CreatedAtAction(nameof(UserList), new { id = result.IdUsuario }, result);

        return BadRequest(result.Mensaje);
    }
    }
}

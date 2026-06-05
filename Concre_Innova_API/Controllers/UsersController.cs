using Microsoft.AspNetCore.Mvc;
using Concre_Innova_API.Repositories.Users;
using System.Collections.Generic;
using Concre_Innova_API.Models.DTOs.Responses;
using Concre_Innova_API.Services;

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

    [HttpGet]
    public async Task<ActionResult<IEnumerable<UserResponseDto>>> GetUsers()
    {
        var users = await _userService.GetUsersAsync();
        return Ok(users);
    }
    }
}

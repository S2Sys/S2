using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartWorkz.S2.Application;

namespace SmartWorkz.S2.Api;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly ILoginUseCase _loginUseCase;
    private readonly IGetCurrentUserUseCase _getCurrentUserUseCase;

    public AuthController(
        ILoginUseCase loginUseCase,
        IGetCurrentUserUseCase getCurrentUserUseCase)
    {
        _loginUseCase = loginUseCase ?? throw new ArgumentNullException(nameof(loginUseCase));
        _getCurrentUserUseCase = getCurrentUserUseCase ?? throw new ArgumentNullException(nameof(getCurrentUserUseCase));
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        try
        {
            var result = await _loginUseCase.ExecuteAsync(request);
            return Ok(result);
        }
        catch (UnauthorizedAccessException)
        {
            return Unauthorized(new { message = "Invalid email or password." });
        }
    }

    [HttpPost("logout")]
    [Authorize]
    public IActionResult Logout()
    {
        return Ok(new { message = "Logged out successfully." });
    }

    [HttpGet("me")]
    [Authorize]
    public async Task<IActionResult> GetCurrentUser()
    {
        try
        {
            var user = await _getCurrentUserUseCase.ExecuteAsync(User);
            return Ok(user);
        }
        catch (UnauthorizedAccessException)
        {
            return Unauthorized(new { message = "Invalid token." });
        }
    }
}

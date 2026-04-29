using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SmartWorkz.S2.Application;

namespace SmartWorkz.S2.Api;

/// <summary>
/// Authentication endpoints for admin login and user management.
/// </summary>
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

    /// <summary>
    /// Authenticates a user with email and password, returns JWT token.
    /// </summary>
    /// <param name="request">Login credentials (email and password)</param>
    /// <returns>JWT token, user ID, email, full name, and role</returns>
    [HttpPost("login")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(LoginResult), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
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

    /// <summary>
    /// Logs out the current user by invalidating their session.
    /// </summary>
    /// <returns>Success message</returns>
    [HttpPost("logout")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public IActionResult Logout()
    {
        return Ok(new { message = "Logged out successfully." });
    }

    /// <summary>
    /// Retrieves the current authenticated user's information.
    /// </summary>
    /// <returns>User object with ID, email, full name, phone, role, and status</returns>
    [HttpGet("me")]
    [Authorize]
    [ProducesResponseType(typeof(UserDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
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

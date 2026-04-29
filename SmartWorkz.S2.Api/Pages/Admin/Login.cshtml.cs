using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using System.Security.Claims;
using SmartWorkz.S2.Application;

namespace SmartWorkz.S2.Api.Pages.Admin;

public class LoginModel : PageModel
{
    private readonly ILoginUseCase _loginUseCase;
    private readonly ILogger<LoginModel> _logger;

    [BindProperty]
    public LoginRequest Input { get; set; } = new();

    public LoginModel(ILoginUseCase loginUseCase, ILogger<LoginModel> logger)
    {
        _loginUseCase = loginUseCase ?? throw new ArgumentNullException(nameof(loginUseCase));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<IActionResult> OnPostAsync(string? returnUrl = null)
    {
        if (!ModelState.IsValid)
            return Page();

        try
        {
            var result = await _loginUseCase.ExecuteAsync(Input);

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, result.UserId.ToString()),
                new Claim(ClaimTypes.Email, result.Email),
                new Claim(ClaimTypes.Name, result.FullName),
                new Claim(ClaimTypes.Role, result.Role)
            };

            var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
            var authProperties = new AuthenticationProperties
            {
                IsPersistent = true,
                ExpiresUtc = DateTimeOffset.UtcNow.AddDays(30)
            };

            await HttpContext.SignInAsync(
                CookieAuthenticationDefaults.AuthenticationScheme,
                new ClaimsPrincipal(claimsIdentity),
                authProperties);

            _logger.LogInformation("User {Email} logged in successfully.", result.Email);
            return LocalRedirect(returnUrl ?? "/admin/dashboard");
        }
        catch (UnauthorizedAccessException)
        {
            ModelState.AddModelError(string.Empty, "Invalid email or password.");
            _logger.LogWarning("Failed login attempt for email: {Email}", Input.Email);
            return Page();
        }
    }
}

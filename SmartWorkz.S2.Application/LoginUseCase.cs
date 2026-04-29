using SmartWorkz.S2.Domain;
using SmartWorkz.S2.Infrastructure;

namespace SmartWorkz.S2.Application;

public class LoginUseCase : ILoginUseCase
{
    private readonly IUserRepository _userRepository;
    private readonly IUserRoleRepository _userRoleRepository;
    private readonly BcryptPasswordService _passwordService;
    private readonly JwtTokenService _jwtService;

    public LoginUseCase(
        IUserRepository userRepository,
        IUserRoleRepository userRoleRepository,
        BcryptPasswordService passwordService,
        JwtTokenService jwtService)
    {
        _userRepository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));
        _userRoleRepository = userRoleRepository ?? throw new ArgumentNullException(nameof(userRoleRepository));
        _passwordService = passwordService ?? throw new ArgumentNullException(nameof(passwordService));
        _jwtService = jwtService ?? throw new ArgumentNullException(nameof(jwtService));
    }

    public async Task<LoginResult> ExecuteAsync(LoginRequest request)
    {
        if (request == null)
            throw new ArgumentNullException(nameof(request));

        var user = await _userRepository.GetByEmailAsync(request.Email);
        if (user == null || !user.IsActive)
            throw new UnauthorizedAccessException("Invalid credentials.");

        if (!_passwordService.VerifyPassword(request.Password, user.PasswordHash))
            throw new UnauthorizedAccessException("Invalid credentials.");

        var roles = await _userRoleRepository.GetRolesByUserIdAsync(user.UserID);
        var role = roles.FirstOrDefault()?.RoleName ?? "User";

        var token = _jwtService.IssueToken(user.UserID, user.Email, role);

        return new LoginResult
        {
            Token = token,
            UserId = user.UserID,
            Email = user.Email,
            FullName = user.FullName,
            Role = role
        };
    }
}

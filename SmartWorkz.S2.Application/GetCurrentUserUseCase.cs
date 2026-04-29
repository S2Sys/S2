using System.Security.Claims;
using SmartWorkz.S2.Domain;

namespace SmartWorkz.S2.Application;

public class GetCurrentUserUseCase : IGetCurrentUserUseCase
{
    private readonly IUserRepository _userRepository;

    public GetCurrentUserUseCase(IUserRepository userRepository)
    {
        _userRepository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));
    }

    public async Task<UserDto> ExecuteAsync(ClaimsPrincipal principal)
    {
        if (principal == null)
            throw new ArgumentNullException(nameof(principal));

        var userIdClaim = principal.FindFirst(ClaimTypes.NameIdentifier);
        if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out var userId))
            throw new UnauthorizedAccessException("Invalid token.");

        var user = await _userRepository.GetByIdAsync(userId);

        var roleClaim = principal.FindFirst(ClaimTypes.Role)?.Value ?? "User";

        return new UserDto
        {
            UserId = user.UserID,
            Email = user.Email,
            FullName = user.FullName,
            Phone = user.Phone,
            IsActive = user.IsActive,
            Role = roleClaim
        };
    }
}

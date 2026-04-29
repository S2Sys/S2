using System.Security.Claims;

namespace SmartWorkz.S2.Application;

public interface IGetCurrentUserUseCase
{
    Task<UserDto> ExecuteAsync(ClaimsPrincipal principal);
}

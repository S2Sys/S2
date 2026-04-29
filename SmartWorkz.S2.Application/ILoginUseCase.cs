namespace SmartWorkz.S2.Application;

public interface ILoginUseCase
{
    Task<LoginResult> ExecuteAsync(LoginRequest request);
}

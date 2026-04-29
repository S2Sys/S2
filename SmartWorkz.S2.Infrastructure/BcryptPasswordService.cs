using BCrypt.Net;

namespace SmartWorkz.S2.Infrastructure;

public class BcryptPasswordService
{
    private const int WorkFactor = 12;

    public string HashPassword(string plainPassword)
    {
        if (string.IsNullOrWhiteSpace(plainPassword))
            throw new ArgumentException("Password cannot be empty.", nameof(plainPassword));
        return BCrypt.Net.BCrypt.HashPassword(plainPassword, WorkFactor);
    }

    public bool VerifyPassword(string plainPassword, string hash)
    {
        if (string.IsNullOrWhiteSpace(plainPassword) || string.IsNullOrWhiteSpace(hash))
            return false;
        return BCrypt.Net.BCrypt.Verify(plainPassword, hash);
    }
}

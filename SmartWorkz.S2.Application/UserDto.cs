namespace SmartWorkz.S2.Application;

public class UserDto
{
    public int UserId { get; set; }
    public string Email { get; set; } = null!;
    public string FullName { get; set; } = null!;
    public string Phone { get; set; } = null!;
    public bool IsActive { get; set; }
    public string Role { get; set; } = null!;
}

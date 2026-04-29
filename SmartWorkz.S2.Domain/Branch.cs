namespace SmartWorkz.S2.Domain;

public class Branch
{
    public int BranchID { get; set; }
    public string BranchName { get; set; } = null!;
    public string Location { get; set; } = null!;
    public string Address { get; set; } = null!;
    public string Phone { get; set; } = null!;
    public string Email { get; set; } = null!;
    public bool IsHeadquarters { get; set; }
    public string RowState { get; set; } = "Active";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}

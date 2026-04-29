namespace SmartWorkz.S2.Domain;

public class LookupType
{
    public int LookupTypeID { get; set; }
    public string LookupCategory { get; set; } = null!;
    public string LookupValue { get; set; } = null!;
    public string DisplayLabel { get; set; } = null!;
    public int? ParentLookupTypeID { get; set; }
    public int DisplayOrder { get; set; }
    public bool IsActive { get; set; } = true;
    public string RowState { get; set; } = "Active";
}

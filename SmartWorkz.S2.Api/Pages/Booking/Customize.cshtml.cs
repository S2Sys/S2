using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace SmartWorkz.S2.Api.Pages.Booking;

public class BookingCustomizeModel : PageModel
{
    public MockPackageDto? Package { get; set; }
    public string? BookingDate { get; set; }
    public string? BookingTime { get; set; }
    public string? BookingLocation { get; set; }

    public void OnGet()
    {
        var packageId = HttpContext.Session.GetInt32("BookingPackageId");
        BookingDate = HttpContext.Session.GetString("BookingDate");
        BookingTime = HttpContext.Session.GetString("BookingTime");
        BookingLocation = HttpContext.Session.GetString("BookingLocation");

        if (packageId.HasValue)
        {
            Package = MockDataService.GetMockPackages().FirstOrDefault(p => p.Id == packageId.Value);
        }

        if (Package == null || string.IsNullOrEmpty(BookingDate))
        {
            RedirectToPage("Index");
        }
    }

    public IActionResult OnPost(int[]? selectedAddOns)
    {
        HttpContext.Session.SetString("SelectedAddOns", string.Join(",", selectedAddOns ?? new int[0]));
        return RedirectToPage("ClientInfo");
    }
}

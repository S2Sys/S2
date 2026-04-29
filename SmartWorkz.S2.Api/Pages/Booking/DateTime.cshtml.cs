using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace SmartWorkz.S2.Api.Pages.Booking;

public class BookingDateTimeModel : PageModel
{
    public MockPackageDto? Package { get; set; }

    public void OnGet()
    {
        var packageId = HttpContext.Session.GetInt32("BookingPackageId");
        if (packageId.HasValue)
        {
            Package = MockDataService.GetMockPackages().FirstOrDefault(p => p.Id == packageId.Value);
        }

        if (Package == null)
        {
            RedirectToPage("Index");
        }
    }

    public IActionResult OnPost(string bookingDate, string bookingTime, string location)
    {
        if (string.IsNullOrEmpty(bookingDate) || string.IsNullOrEmpty(bookingTime) || string.IsNullOrEmpty(location))
        {
            ModelState.AddModelError(string.Empty, "Please fill in all fields");
            OnGet();
            return Page();
        }

        HttpContext.Session.SetString("BookingDate", bookingDate);
        HttpContext.Session.SetString("BookingTime", bookingTime);
        HttpContext.Session.SetString("BookingLocation", location);

        return RedirectToPage("Customize");
    }
}

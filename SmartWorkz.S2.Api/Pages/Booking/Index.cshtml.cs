using SmartWorkz.S2.Api.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace SmartWorkz.S2.Api.Pages.Booking;

public class BookingIndexModel : PageModel
{
    public List<MockPackageDto> Packages { get; set; } = new();

    public void OnGet()
    {
        Packages = MockDataService.GetMockPackages();
    }

    public IActionResult OnPost(int packageId)
    {
        if (packageId <= 0)
        {
            ModelState.AddModelError(string.Empty, "Please select a package");
            Packages = MockDataService.GetMockPackages();
            return Page();
        }

        var package = MockDataService.GetMockPackages().FirstOrDefault(p => p.Id == packageId);
        if (package == null)
        {
            ModelState.AddModelError(string.Empty, "Package not found");
            Packages = MockDataService.GetMockPackages();
            return Page();
        }

        HttpContext.Session.SetInt32("BookingPackageId", packageId);
        return RedirectToPage("DateTime");
    }
}

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace SmartWorkz.S2.Api.Pages.Booking;

public class BookingConfirmModel : PageModel
{
    public MockPackageDto? Package { get; set; }
    public string? BookingDate { get; set; }
    public string? BookingTime { get; set; }
    public string? BookingLocation { get; set; }
    public string? ClientFullName { get; set; }
    public string? ClientEmail { get; set; }
    public string? ClientPhone { get; set; }
    public string? ClientPreferredContact { get; set; }
    public string? ClientAddress { get; set; }
    public string? ClientSpecialRequests { get; set; }
    public string? SelectedAddOnsDisplay { get; set; }
    public decimal TotalPrice { get; set; }

    public void OnGet()
    {
        var packageId = HttpContext.Session.GetInt32("BookingPackageId");
        BookingDate = HttpContext.Session.GetString("BookingDate");
        BookingTime = HttpContext.Session.GetString("BookingTime");
        BookingLocation = HttpContext.Session.GetString("BookingLocation");
        ClientFullName = HttpContext.Session.GetString("ClientFullName");
        ClientEmail = HttpContext.Session.GetString("ClientEmail");
        ClientPhone = HttpContext.Session.GetString("ClientPhone");
        ClientPreferredContact = HttpContext.Session.GetString("ClientPreferredContact");
        ClientAddress = HttpContext.Session.GetString("ClientAddress");
        ClientSpecialRequests = HttpContext.Session.GetString("ClientSpecialRequests");

        if (packageId.HasValue)
        {
            Package = MockDataService.GetMockPackages().FirstOrDefault(p => p.Id == packageId.Value);
        }

        TotalPrice = Package?.BasePrice ?? 0;

        // Calculate add-on prices
        var selectedAddOnsStr = HttpContext.Session.GetString("SelectedAddOns");
        if (!string.IsNullOrEmpty(selectedAddOnsStr) && Package?.AddOns != null)
        {
            var selectedIds = selectedAddOnsStr.Split(',').Select(int.Parse).ToList();
            var htmlParts = new List<string>();

            foreach (var addon in Package.AddOns.Where(a => selectedIds.Contains(a.Id)))
            {
                TotalPrice += addon.Price;
                htmlParts.Add($"<div class=\"d-flex justify-content-between small mb-1\"><span>{addon.Name}</span><span>₹{addon.Price:N0}</span></div>");
            }

            if (htmlParts.Count > 0)
            {
                SelectedAddOnsDisplay = string.Join("", htmlParts);
            }
        }

        if (Package == null || string.IsNullOrEmpty(ClientEmail))
        {
            RedirectToPage("Index");
        }
    }

    public IActionResult OnPost()
    {
        // Clear booking session
        HttpContext.Session.Clear();

        // Redirect to success page
        return RedirectToPage("Success");
    }
}

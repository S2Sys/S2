using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace SmartWorkz.S2.Api.Pages.Booking;

public class BookingClientInfoModel : PageModel
{
    public void OnGet()
    {
        var packageId = HttpContext.Session.GetInt32("BookingPackageId");
        var bookingDate = HttpContext.Session.GetString("BookingDate");

        if (!packageId.HasValue || string.IsNullOrEmpty(bookingDate))
        {
            RedirectToPage("Index");
        }
    }

    public IActionResult OnPost(string fullName, string email, string phone, string preferredContact,
                                string address, string specialRequests, bool agreeTerms)
    {
        if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(phone))
        {
            ModelState.AddModelError(string.Empty, "Please fill in all required fields");
            return Page();
        }

        if (!agreeTerms)
        {
            ModelState.AddModelError(string.Empty, "Please agree to the terms and conditions");
            return Page();
        }

        HttpContext.Session.SetString("ClientFullName", fullName);
        HttpContext.Session.SetString("ClientEmail", email);
        HttpContext.Session.SetString("ClientPhone", phone);
        HttpContext.Session.SetString("ClientPreferredContact", preferredContact ?? "email");
        HttpContext.Session.SetString("ClientAddress", address ?? "");
        HttpContext.Session.SetString("ClientSpecialRequests", specialRequests ?? "");

        return RedirectToPage("Confirm");
    }
}

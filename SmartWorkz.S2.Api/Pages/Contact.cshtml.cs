using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace SmartWorkz.S2.Api.Pages;

public class ContactModel : PageModel
{
    public void OnGet()
    {
        // Contact page with form
    }

    public IActionResult OnPost(string fullName, string email, string phone, string subject, string message, bool subscribe)
    {
        if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(subject) || string.IsNullOrEmpty(message))
        {
            ModelState.AddModelError(string.Empty, "Please fill in all required fields");
            return Page();
        }

        // In a real application, you would save this to the database and send an email
        // For now, just set a success message
        TempData["SuccessMessage"] = "Thank you for your message! We'll get back to you soon.";
        return RedirectToPage();
    }
}

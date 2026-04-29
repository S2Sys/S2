using SmartWorkz.S2.Api.Services;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace SmartWorkz.S2.Api.Pages.Admin;

public class DashboardModel : PageModel
{
    public Dictionary<string, object> DashboardStats { get; set; } = new();
    public List<MockBookingDto> RecentBookings { get; set; } = new();

    public void OnGet()
    {
        DashboardStats = MockDataService.GetDashboardStats();
        RecentBookings = MockDataService.GetMockBookings().Take(5).ToList();
    }
}

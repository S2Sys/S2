using SmartWorkz.S2.Api.Services;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace SmartWorkz.S2.Api.Pages;

public class PackagesModel : PageModel
{
    public List<MockPackageDto> Packages { get; set; } = new();

    public void OnGet()
    {
        Packages = MockDataService.GetMockPackages();
    }
}

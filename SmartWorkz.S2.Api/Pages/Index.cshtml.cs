using Microsoft.AspNetCore.Mvc.RazorPages;
using SmartWorkz.S2.Api.Services;

namespace SmartWorkz.S2.Api.Pages;

public class IndexModel : PageModel
{
    public List<MockGalleryDto> FeaturedGalleries { get; set; } = new();
    public List<MockPackageDto> Packages { get; set; } = new();

    public void OnGet()
    {
        FeaturedGalleries = MockDataService.GetMockGalleries().Where(g => g.IsFeatured).ToList();
        Packages = MockDataService.GetMockPackages();
    }
}

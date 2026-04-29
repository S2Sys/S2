using SmartWorkz.S2.Api.Services;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace SmartWorkz.S2.Api.Pages;

public class GalleryModel : PageModel
{
    public List<MockGalleryDto> Galleries { get; set; } = new();
    public List<string> Categories { get; set; } = new();

    public void OnGet()
    {
        Galleries = MockDataService.GetMockGalleries();
        Categories = Galleries.Select(g => g.Category).Distinct().ToList();
    }
}

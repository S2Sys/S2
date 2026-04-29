using Microsoft.AspNetCore.Mvc.RazorPages;

namespace SmartWorkz.S2.Api.Pages.Portfolio;

public class PortfolioDetailModel : PageModel
{
    public MockGalleryDto? Gallery { get; set; }
    public List<MockGalleryImageDto> GalleryImages { get; set; } = new();

    public void OnGet(string gallery)
    {
        var allGalleries = MockDataService.GetMockGalleries();
        var normalizedGalleryName = gallery.Replace("-", " ");

        Gallery = allGalleries.FirstOrDefault(g =>
            g.Title.Equals(normalizedGalleryName, StringComparison.OrdinalIgnoreCase));

        if (Gallery != null)
        {
            GalleryImages = MockDataService.GetMockGalleryImages()
                .Where(img => img.GalleryId == Gallery.Id)
                .ToList();
        }
    }
}

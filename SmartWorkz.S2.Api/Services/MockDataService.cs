namespace SmartWorkz.S2.Api.Services;

public class MockGalleryDto
{
    public int Id { get; set; }
    public string Title { get; set; }
    public string Description { get; set; }
    public string Category { get; set; }
    public string ThumbnailUrl { get; set; }
    public bool IsFeatured { get; set; }
    public int ImageCount { get; set; }
    public List<MockGalleryImageDto> Images { get; set; } = new();
}

public class MockGalleryImageDto
{
    public int Id { get; set; }
    public int GalleryId { get; set; }
    public string ImageUrl { get; set; }
    public string ThumbnailUrl { get; set; }
    public string Caption { get; set; }
    public string AltText { get; set; }
}

public class MockPackageDto
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Description { get; set; }
    public decimal BasePrice { get; set; }
    public int DurationHours { get; set; }
    public List<string> Included { get; set; } = new();
    public bool IsFeatured { get; set; }
    public string Badge { get; set; }
    public int MaxGalleryImages { get; set; }
    public int MaxVideoDurationMinutes { get; set; }
    public bool IncludedRawFiles { get; set; }
    public bool IncludedAlbum { get; set; }
    public bool IncludedRetouching { get; set; }
    public string RetouchingLevel { get; set; }
    public bool IncludedSecondPhotographer { get; set; }
    public List<MockPackageAddOnDto> AddOns { get; set; } = new();
}

public class MockPackageAddOnDto
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Description { get; set; }
    public decimal Price { get; set; }
}

public class MockBookingDto
{
    public int Id { get; set; }
    public string ClientName { get; set; }
    public string PackageName { get; set; }
    public DateTime BookingDate { get; set; }
    public string Time { get; set; }
    public string Status { get; set; }
    public decimal Amount { get; set; }
    public string Location { get; set; }
}

public class MockClientDto
{
    public int Id { get; set; }
    public string FullName { get; set; }
    public string Email { get; set; }
    public string Phone { get; set; }
    public int BookingCount { get; set; }
}

public class MockDailyTaskDto
{
    public int Id { get; set; }
    public string Title { get; set; }
    public string Status { get; set; } // Pending, InProgress, Completed
    public string Priority { get; set; } // Low, Medium, High, Critical
    public DateTime DueDate { get; set; }
    public string BookingReference { get; set; }
}

public static class MockDataService
{
    public static List<MockGalleryDto> GetMockGalleries()
    {
        return new()
        {
            new MockGalleryDto
            {
                Id = 1,
                Title = "Wedding 2024",
                Description = "Beautiful wedding ceremonies and receptions",
                Category = "Wedding",
                ThumbnailUrl = "/images/gallery-1.jpg",
                IsFeatured = true,
                ImageCount = 45,
                Images = new()
                {
                    new MockGalleryImageDto { Id = 1, ImageUrl = "/images/wedding-1.jpg", ThumbnailUrl = "/images/wedding-1-thumb.jpg", Caption = "Bride and Groom", AltText = "Wedding ceremony" },
                    new MockGalleryImageDto { Id = 2, ImageUrl = "/images/wedding-2.jpg", ThumbnailUrl = "/images/wedding-2-thumb.jpg", Caption = "Reception Dance", AltText = "Wedding reception" },
                }
            },
            new MockGalleryDto
            {
                Id = 2,
                Title = "Corporate Events",
                Description = "Professional corporate photography",
                Category = "Corporate",
                ThumbnailUrl = "/images/gallery-2.jpg",
                IsFeatured = true,
                ImageCount = 32,
                Images = new()
                {
                    new MockGalleryImageDto { Id = 3, ImageUrl = "/images/corporate-1.jpg", ThumbnailUrl = "/images/corporate-1-thumb.jpg", Caption = "Conference", AltText = "Corporate event" },
                }
            },
            new MockGalleryDto
            {
                Id = 3,
                Title = "Portraits",
                Description = "Professional portrait photography",
                Category = "Portrait",
                ThumbnailUrl = "/images/gallery-3.jpg",
                IsFeatured = false,
                ImageCount = 28,
                Images = new()
                {
                    new MockGalleryImageDto { Id = 4, ImageUrl = "/images/portrait-1.jpg", ThumbnailUrl = "/images/portrait-1-thumb.jpg", Caption = "Studio Portrait", AltText = "Professional portrait" },
                }
            },
            new MockGalleryDto
            {
                Id = 4,
                Title = "Events 2024",
                Description = "Special events and celebrations",
                Category = "Event",
                ThumbnailUrl = "/images/gallery-4.jpg",
                IsFeatured = true,
                ImageCount = 56,
                Images = new()
            }
        };
    }

    public static List<MockPackageDto> GetMockPackages()
    {
        return new()
        {
            new MockPackageDto
            {
                Id = 1,
                Name = "Bronze Package",
                Description = "Perfect for small events and intimate gatherings",
                BasePrice = 25000,
                DurationHours = 4,
                Included = new() { "4 Hours Photography", "100 Edited Photos", "Digital Delivery", "1 Album" },
                IsFeatured = false,
                Badge = null,
                MaxGalleryImages = 100,
                MaxVideoDurationMinutes = 0,
                IncludedRawFiles = false,
                IncludedAlbum = true,
                IncludedRetouching = true,
                RetouchingLevel = "Standard",
                IncludedSecondPhotographer = false,
                AddOns = new() { new MockPackageAddOnDto { Id = 1, Name = "Extra Hour Photography", Description = "Additional hour of photography coverage", Price = 5000 }, new MockPackageAddOnDto { Id = 4, Name = "Video Highlights Reel", Description = "Professional video highlights reel", Price = 8000 } }
            },
            new MockPackageDto
            {
                Id = 2,
                Name = "Silver Package",
                Description = "Most popular choice for weddings",
                BasePrice = 50000,
                DurationHours = 8,
                Included = new() { "8 Hours Photography", "500 Edited Photos", "Premium Album", "Video Highlights", "Digital Delivery" },
                IsFeatured = true,
                Badge = "Most Popular",
                MaxGalleryImages = 500,
                MaxVideoDurationMinutes = 30,
                IncludedRawFiles = true,
                IncludedAlbum = true,
                IncludedRetouching = true,
                RetouchingLevel = "Premium",
                IncludedSecondPhotographer = false,
                AddOns = new() { new MockPackageAddOnDto { Id = 1, Name = "Extra Hour Photography", Description = "Additional hour of photography coverage", Price = 5000 }, new MockPackageAddOnDto { Id = 2, Name = "Drone Photography", Description = "Aerial drone footage and photography", Price = 10000 }, new MockPackageAddOnDto { Id = 3, Name = "Pre-Wedding Shoot", Description = "Engagement or pre-wedding photoshoot", Price = 15000 } }
            },
            new MockPackageDto
            {
                Id = 3,
                Name = "Gold Package",
                Description = "Premium package with everything included",
                BasePrice = 75000,
                DurationHours = 12,
                Included = new() { "12 Hours Photography", "2nd Photographer", "1000 Edited Photos", "Premium Album", "4K Video", "Drone Footage", "Unlimited Prints" },
                IsFeatured = true,
                Badge = "Premium",
                MaxGalleryImages = 1000,
                MaxVideoDurationMinutes = 120,
                IncludedRawFiles = true,
                IncludedAlbum = true,
                IncludedRetouching = true,
                RetouchingLevel = "Luxury",
                IncludedSecondPhotographer = true,
                AddOns = new() { new MockPackageAddOnDto { Id = 1, Name = "Extra Hour Photography", Description = "Additional hour of photography coverage", Price = 5000 }, new MockPackageAddOnDto { Id = 5, Name = "Premium Album Upgrade", Description = "Upgrade to premium quality album", Price = 5000 } }
            }
        };
    }

    public static List<MockGalleryImageDto> GetMockGalleryImages()
    {
        return new()
        {
            new MockGalleryImageDto { Id = 1, GalleryId = 1, ImageUrl = "/images/wedding-1.jpg", ThumbnailUrl = "/images/wedding-1-thumb.jpg", Caption = "Bride and Groom", AltText = "Wedding ceremony" },
            new MockGalleryImageDto { Id = 2, GalleryId = 1, ImageUrl = "/images/wedding-2.jpg", ThumbnailUrl = "/images/wedding-2-thumb.jpg", Caption = "Reception Dance", AltText = "Wedding reception" },
            new MockGalleryImageDto { Id = 3, GalleryId = 2, ImageUrl = "/images/corporate-1.jpg", ThumbnailUrl = "/images/corporate-1-thumb.jpg", Caption = "Conference", AltText = "Corporate event" },
            new MockGalleryImageDto { Id = 4, GalleryId = 3, ImageUrl = "/images/portrait-1.jpg", ThumbnailUrl = "/images/portrait-1-thumb.jpg", Caption = "Studio Portrait", AltText = "Professional portrait" },
            new MockGalleryImageDto { Id = 5, GalleryId = 4, ImageUrl = "/images/event-1.jpg", ThumbnailUrl = "/images/event-1-thumb.jpg", Caption = "Event Celebration", AltText = "Special event" }
        };
    }

    public static List<MockPackageAddOnDto> GetMockAddOns()
    {
        return new()
        {
            new MockPackageAddOnDto { Id = 1, Name = "Extra Hour Photography", Description = "Additional hour of photography coverage", Price = 5000 },
            new MockPackageAddOnDto { Id = 2, Name = "Drone Photography", Description = "Aerial drone footage and photography", Price = 10000 },
            new MockPackageAddOnDto { Id = 3, Name = "Pre-Wedding Shoot", Description = "Engagement or pre-wedding photoshoot", Price = 15000 },
            new MockPackageAddOnDto { Id = 4, Name = "Video Highlights Reel", Description = "Professional video highlights reel", Price = 8000 },
            new MockPackageAddOnDto { Id = 5, Name = "Premium Album Upgrade", Description = "Upgrade to premium quality album", Price = 5000 }
        };
    }

    public static List<MockBookingDto> GetMockBookings()
    {
        return new()
        {
            new MockBookingDto { Id = 1, ClientName = "Raj Kapoor", PackageName = "Gold Package", BookingDate = DateTime.Now.AddDays(15), Time = "10:00 AM", Status = "Confirmed", Amount = 85000, Location = "Grand Palace Hotel" },
            new MockBookingDto { Id = 2, ClientName = "Priya Sharma", PackageName = "Silver Package", BookingDate = DateTime.Now.AddDays(20), Time = "02:00 PM", Status = "Pending", Amount = 50000, Location = "Taj Gardens" },
            new MockBookingDto { Id = 3, ClientName = "Amit Gupta", PackageName = "Bronze Package", BookingDate = DateTime.Now.AddDays(8), Time = "06:00 PM", Status = "Completed", Amount = 25000, Location = "Community Hall" },
            new MockBookingDto { Id = 4, ClientName = "Anjali Verma", PackageName = "Gold Package", BookingDate = DateTime.Now.AddDays(25), Time = "09:00 AM", Status = "Confirmed", Amount = 95000, Location = "Banquet Hall" },
            new MockBookingDto { Id = 5, ClientName = "Sanjay Patel", PackageName = "Silver Package", BookingDate = DateTime.Now.AddDays(30), Time = "11:00 AM", Status = "Pending", Amount = 55000, Location = "Convention Center" }
        };
    }

    public static List<MockClientDto> GetMockClients()
    {
        return new()
        {
            new MockClientDto { Id = 1, FullName = "Raj Kapoor", Email = "raj@example.com", Phone = "+91-9999-000001", BookingCount = 3 },
            new MockClientDto { Id = 2, FullName = "Priya Sharma", Email = "priya@example.com", Phone = "+91-9999-000002", BookingCount = 1 },
            new MockClientDto { Id = 3, FullName = "Amit Gupta", Email = "amit@example.com", Phone = "+91-9999-000003", BookingCount = 5 },
            new MockClientDto { Id = 4, FullName = "Anjali Verma", Email = "anjali@example.com", Phone = "+91-9999-000004", BookingCount = 2 },
            new MockClientDto { Id = 5, FullName = "Sanjay Patel", Email = "sanjay@example.com", Phone = "+91-9999-000005", BookingCount = 4 }
        };
    }

    public static List<MockDailyTaskDto> GetMockTasks()
    {
        return new()
        {
            new MockDailyTaskDto { Id = 1, Title = "Edit wedding photos from Kapoor session", Status = "InProgress", Priority = "High", DueDate = DateTime.Now.AddDays(2), BookingReference = "Booking #1" },
            new MockDailyTaskDto { Id = 2, Title = "Prepare drone footage for Verma booking", Status = "Pending", Priority = "Critical", DueDate = DateTime.Now.AddDays(1), BookingReference = "Booking #4" },
            new MockDailyTaskDto { Id = 3, Title = "Create album layout for Sharma booking", Status = "Pending", Priority = "Medium", DueDate = DateTime.Now.AddDays(5), BookingReference = "Booking #2" },
            new MockDailyTaskDto { Id = 4, Title = "Deliver final photos to Gupta", Status = "Completed", Priority = "High", DueDate = DateTime.Now.AddDays(-2), BookingReference = "Booking #3" },
            new MockDailyTaskDto { Id = 5, Title = "Retouch portraits for Patel session", Status = "InProgress", Priority = "Medium", DueDate = DateTime.Now.AddDays(3), BookingReference = "Booking #5" }
        };
    }

    public static Dictionary<string, object> GetDashboardStats()
    {
        return new()
        {
            { "TotalBookings", 5 },
            { "PendingBookings", 2 },
            { "TotalRevenue", 310000 },
            { "AveragePackagePrice", 62000 },
            { "TotalClients", 5 },
            { "TotalGalleries", 4 },
            { "MonthlyBookings", 3 },
            { "MonthlyRevenue", 155000 }
        };
    }
}

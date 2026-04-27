-- STUDIOS2 Database - Seed Data (Run Third)
-- Populates initial data with simplified naming conventions (CreatedBy, UpdatedBy, DeletedBy)

SET NOCOUNT ON;

-- ============================================
-- SEED ROLES
-- ============================================

PRINT '=== Seeding Roles ===';

DECLARE @AdminRoleId INT, @EditorRoleId INT, @ViewerRoleId INT;

EXEC usp_Roles_Upsert
    @Id = 0,
    @RoleName = 'Admin',
    @Description = 'Full system administration and access',
    @IsActive = 1;

SELECT @AdminRoleId = @@IDENTITY;

EXEC usp_Roles_Upsert
    @Id = 0,
    @RoleName = 'Editor',
    @Description = 'Can manage galleries, packages, and bookings',
    @IsActive = 1;

SELECT @EditorRoleId = @@IDENTITY;

EXEC usp_Roles_Upsert
    @Id = 0,
    @RoleName = 'Viewer',
    @Description = 'Can only view galleries and public content',
    @IsActive = 1;

SELECT @ViewerRoleId = @@IDENTITY;

PRINT 'Roles seeded: Admin=' + CAST(@AdminRoleId AS VARCHAR) + ', Editor=' + CAST(@EditorRoleId AS VARCHAR) + ', Viewer=' + CAST(@ViewerRoleId AS VARCHAR);

-- ============================================
-- SEED ADMIN USER
-- ============================================

PRINT '=== Seeding Admin User ===';

DECLARE @AdminUserId INT;

EXEC usp_Users_Upsert
    @Id = 0,
    @Email = 'admin@smartworkz.com',
    @PasswordHash = '$2a$12$w7m3L9kJ2n4pQ5xR8sT2u.Y6zVa1bCd3eF4gH5iJ6kL7mN8oP9qR0sT1u', -- bcrypt hash for 'Admin@123'
    @FullName = 'Admin User',
    @Phone = '+91-9876543210',
    @Bio = 'System Administrator',
    @ProfilePhotoUrl = NULL,
    @IsActive = 1;

SELECT @AdminUserId = @@IDENTITY;

PRINT 'Admin user created: ID=' + CAST(@AdminUserId AS VARCHAR);

-- Assign Admin role to admin user
EXEC usp_UserRoles_AssignRole
    @UserId = @AdminUserId,
    @RoleId = @AdminRoleId;

PRINT 'Admin role assigned to admin user';

-- ============================================
-- SEED SETTINGS
-- ============================================

PRINT '=== Seeding Settings ===';

EXEC usp_Settings_Upsert @SettingKey = 'SiteName', @SettingValue = 'Studio S2 - Photography & Videography';
EXEC usp_Settings_Upsert @SettingKey = 'SiteDescription', @SettingValue = 'Premium photography and videography services for weddings, portraits, and events';
EXEC usp_Settings_Upsert @SettingKey = 'Currency', @SettingValue = 'INR';
EXEC usp_Settings_Upsert @SettingKey = 'TaxRate', @SettingValue = '0.18';
EXEC usp_Settings_Upsert @SettingKey = 'Email', @SettingValue = 'info@studios2.com';
EXEC usp_Settings_Upsert @SettingKey = 'Phone', @SettingValue = '+91-9876543210';
EXEC usp_Settings_Upsert @SettingKey = 'Address', @SettingValue = '123 Photography Lane, Creative City, India 560001';
EXEC usp_Settings_Upsert @SettingKey = 'TimeZone', @SettingValue = 'Asia/Kolkata';
EXEC usp_Settings_Upsert @SettingKey = 'BookingLeadDays', @SettingValue = '7';

PRINT 'Settings seeded successfully';

-- ============================================
-- SEED GALLERY TYPES
-- ============================================

PRINT '=== Seeding Gallery Types ===';

DECLARE @PhotoGalleryTypeId INT, @VideoGalleryTypeId INT, @SliderTypeId INT;

EXEC usp_GalleryType_Upsert
    @Id = 0,
    @TypeName = 'Photo Gallery',
    @Description = 'Collections of photographs',
    @IsActive = 1;

SELECT @PhotoGalleryTypeId = @@IDENTITY;

EXEC usp_GalleryType_Upsert
    @Id = 0,
    @TypeName = 'Video Gallery',
    @Description = 'Collections of videos',
    @IsActive = 1;

SELECT @VideoGalleryTypeId = @@IDENTITY;

EXEC usp_GalleryType_Upsert
    @Id = 0,
    @TypeName = 'Image Slider',
    @Description = 'Rotating image carousel for homepage',
    @IsActive = 1;

SELECT @SliderTypeId = @@IDENTITY;

PRINT 'Gallery types seeded: PhotoGallery=' + CAST(@PhotoGalleryTypeId AS VARCHAR) + ', VideoGallery=' + CAST(@VideoGalleryTypeId AS VARCHAR) + ', Slider=' + CAST(@SliderTypeId AS VARCHAR);

-- ============================================
-- SEED PHOTO GALLERIES
-- ============================================

PRINT '=== Seeding Photo Galleries ===';

DECLARE @WeddingGalleryId INT, @PortraitGalleryId INT, @CorporateGalleryId INT;

EXEC usp_Gallery_Upsert
    @Id = 0,
    @GalleryTypeId = @PhotoGalleryTypeId,
    @CreatedBy = @AdminUserId,
    @UpdatedBy = @AdminUserId,
    @Title = 'Wedding 2024',
    @Description = 'Beautiful wedding photography collection',
    @Category = 'Wedding',
    @DisplayOrder = 1,
    @IsFeatured = 1,
    @IsPublished = 1;

SELECT @WeddingGalleryId = @@IDENTITY;

EXEC usp_Gallery_Upsert
    @Id = 0,
    @GalleryTypeId = @PhotoGalleryTypeId,
    @CreatedBy = @AdminUserId,
    @UpdatedBy = @AdminUserId,
    @Title = 'Portrait Sessions',
    @Description = 'Professional portrait photography',
    @Category = 'Portrait',
    @DisplayOrder = 2,
    @IsFeatured = 1,
    @IsPublished = 1;

SELECT @PortraitGalleryId = @@IDENTITY;

EXEC usp_Gallery_Upsert
    @Id = 0,
    @GalleryTypeId = @PhotoGalleryTypeId,
    @CreatedBy = @AdminUserId,
    @UpdatedBy = @AdminUserId,
    @Title = 'Corporate Events',
    @Description = 'Corporate and business event photography',
    @Category = 'Corporate',
    @DisplayOrder = 3,
    @IsFeatured = 0,
    @IsPublished = 1;

SELECT @CorporateGalleryId = @@IDENTITY;

PRINT 'Photo galleries seeded: Wedding=' + CAST(@WeddingGalleryId AS VARCHAR) + ', Portrait=' + CAST(@PortraitGalleryId AS VARCHAR) + ', Corporate=' + CAST(@CorporateGalleryId AS VARCHAR);

-- ============================================
-- SEED GALLERY ASSETS (Images)
-- ============================================

PRINT '=== Seeding Gallery Assets (Images) ===';

EXEC usp_GalleryAsset_Upsert
    @Id = 0,
    @GalleryId = @WeddingGalleryId,
    @AssetType = 'Image',
    @MediaUrl = '/assets/images/weddings/photo-001.webp',
    @ThumbnailUrl = '/assets/images/weddings/photo-001-thumb.webp',
    @CreatedBy = @AdminUserId,
    @AltText = 'Wedding ceremony',
    @Caption = 'Beautiful ceremony moment',
    @DisplayOrder = 1;

EXEC usp_GalleryAsset_Upsert
    @Id = 0,
    @GalleryId = @WeddingGalleryId,
    @AssetType = 'Image',
    @MediaUrl = '/assets/images/weddings/photo-002.webp',
    @ThumbnailUrl = '/assets/images/weddings/photo-002-thumb.webp',
    @AltText = 'Bride and groom',
    @Caption = 'Stunning bride and groom',
    @DisplayOrder = 2;

EXEC usp_GalleryAsset_Upsert
    @Id = 0,
    @GalleryId = @WeddingGalleryId,
    @AssetType = 'Image',
    @MediaUrl = '/assets/images/weddings/photo-003.webp',
    @ThumbnailUrl = '/assets/images/weddings/photo-003-thumb.webp',
    @AltText = 'Reception details',
    @Caption = 'Beautiful reception setup',
    @DisplayOrder = 3;

EXEC usp_GalleryAsset_Upsert
    @Id = 0,
    @GalleryId = @PortraitGalleryId,
    @AssetType = 'Image',
    @MediaUrl = '/assets/images/portraits/portrait-001.webp',
    @ThumbnailUrl = '/assets/images/portraits/portrait-001-thumb.webp',
    @AltText = 'Professional portrait',
    @Caption = 'Executive portrait',
    @DisplayOrder = 1;

EXEC usp_GalleryAsset_Upsert
    @Id = 0,
    @GalleryId = @PortraitGalleryId,
    @AssetType = 'Image',
    @MediaUrl = '/assets/images/portraits/portrait-002.webp',
    @ThumbnailUrl = '/assets/images/portraits/portrait-002-thumb.webp',
    @AltText = 'Family portrait',
    @Caption = 'Happy family',
    @DisplayOrder = 2;

PRINT 'Gallery assets (images) seeded successfully';

-- ============================================
-- SEED VIDEO GALLERIES
-- ============================================

PRINT '=== Seeding Video Galleries ===';

DECLARE @WeddingVideoGalleryId INT, @EventVideoGalleryId INT;

EXEC usp_Gallery_Upsert
    @Id = 0,
    @GalleryTypeId = @VideoGalleryTypeId,
    @Title = 'Wedding Videos 2024',
    @Description = 'Professional wedding videography',
    @DisplayOrder = 1,
    @IsFeatured = 1,
    @IsPublished = 1;

SELECT @WeddingVideoGalleryId = @@IDENTITY;

EXEC usp_Gallery_Upsert
    @Id = 0,
    @GalleryTypeId = @VideoGalleryTypeId,
    @Title = 'Event Highlights',
    @Description = 'Event coverage and highlights',
    @DisplayOrder = 2,
    @IsFeatured = 0,
    @IsPublished = 1;

SELECT @EventVideoGalleryId = @@IDENTITY;

PRINT 'Video galleries seeded: WeddingVideos=' + CAST(@WeddingVideoGalleryId AS VARCHAR) + ', Events=' + CAST(@EventVideoGalleryId AS VARCHAR);

-- ============================================
-- SEED GALLERY ASSETS (Videos)
-- ============================================

PRINT '=== Seeding Gallery Assets (Videos) ===';

EXEC usp_GalleryAsset_Upsert
    @Id = 0,
    @GalleryId = @WeddingVideoGalleryId,
    @AssetType = 'Video',
    @MediaUrl = '/assets/videos/wedding-001.mp4',
    @ThumbnailUrl = '/assets/videos/wedding-001-thumb.webp',
    @Caption = 'Wedding highlights',
    @DurationMinutes = 5,
    @DisplayOrder = 1;

EXEC usp_GalleryAsset_Upsert
    @Id = 0,
    @GalleryId = @WeddingVideoGalleryId,
    @AssetType = 'Video',
    @MediaUrl = '/assets/videos/wedding-002.mp4',
    @ThumbnailUrl = '/assets/videos/wedding-002-thumb.webp',
    @Caption = 'Ceremony video',
    @DurationMinutes = 3,
    @DisplayOrder = 2;

PRINT 'Gallery assets (videos) seeded successfully';

-- ============================================
-- SEED IMAGE SLIDER
-- ============================================

PRINT '=== Seeding Image Slider ===';

DECLARE @SliderId INT;

EXEC usp_Gallery_Upsert
    @Id = 0,
    @GalleryTypeId = @SliderTypeId,
    @Title = 'Featured Work',
    @Description = 'Rotating carousel of featured projects',
    @DisplayOrder = 1,
    @IsFeatured = 1,
    @IsPublished = 1,
    @RotationSpeed = 5;

SELECT @SliderId = @@IDENTITY;

PRINT 'Image slider created: ID=' + CAST(@SliderId AS VARCHAR);

-- ============================================
-- SEED SLIDER ASSETS (Slides)
-- ============================================

PRINT '=== Seeding Slider Assets (Slides) ===';

EXEC usp_GalleryAsset_Upsert
    @Id = 0,
    @GalleryId = @SliderId,
    @AssetType = 'Slide',
    @MediaUrl = '/assets/images/slider/slide-001.webp',
    @ThumbnailUrl = '/assets/images/slider/slide-001-thumb.webp',
    @LinkUrl = '/portfolio/weddings',
    @Caption = 'Wedding Photography',
    @DisplayOrder = 1;

EXEC usp_GalleryAsset_Upsert
    @Id = 0,
    @GalleryId = @SliderId,
    @AssetType = 'Slide',
    @MediaUrl = '/assets/images/slider/slide-002.webp',
    @ThumbnailUrl = '/assets/images/slider/slide-002-thumb.webp',
    @LinkUrl = '/portfolio/portraits',
    @Caption = 'Portrait Sessions',
    @DisplayOrder = 2;

EXEC usp_GalleryAsset_Upsert
    @Id = 0,
    @GalleryId = @SliderId,
    @AssetType = 'Slide',
    @MediaUrl = '/assets/images/slider/slide-003.webp',
    @ThumbnailUrl = '/assets/images/slider/slide-003-thumb.webp',
    @LinkUrl = '/portfolio/events',
    @Caption = 'Corporate Events',
    @DisplayOrder = 3;

PRINT 'Slider assets (slides) seeded successfully';

-- ============================================
-- SEED PHOTOGRAPHY PACKAGES
-- ============================================

PRINT '=== Seeding Photography Packages ===';

DECLARE @SilverPkgId INT, @GoldPkgId INT, @PlatinumPkgId INT;

EXEC usp_PhotographyPackage_Upsert
    @Id = 0,
    @PackageName = 'Silver Package',
    @PackageDescription = 'Perfect for intimate celebrations',
    @BasePrice = 25000,
    @Currency = 'INR',
    @DurationHours = 4,
    @MaxGalleryImages = 200,
    @MaxVideoDurationMinutes = 0,
    @IncludedRawFiles = 0,
    @IncludedAlbum = 0,
    @IncludedRetouching = 1,
    @RetouchingLevel = 'Basic',
    @IncludedSecondPhotographer = 0,
    @IsActive = 1,
    @IsFeatured = 0,
    @DisplayOrder = 1,
    @CreatedBy = @AdminUserId,
    @UpdatedBy = @AdminUserId;

SELECT @SilverPkgId = @@IDENTITY;

EXEC usp_PhotographyPackage_Upsert
    @Id = 0,
    @PackageName = 'Gold Package',
    @PackageDescription = 'Ideal for weddings and major events',
    @BasePrice = 50000,
    @Currency = 'INR',
    @DurationHours = 8,
    @MaxGalleryImages = 500,
    @MaxVideoDurationMinutes = 10,
    @IncludedRawFiles = 1,
    @IncludedAlbum = 1,
    @IncludedRetouching = 1,
    @RetouchingLevel = 'Premium',
    @IncludedSecondPhotographer = 0,
    @IsActive = 1,
    @IsFeatured = 1,
    @DisplayOrder = 2,
    @CreatedBy = @AdminUserId,
    @UpdatedBy = @AdminUserId;

SELECT @GoldPkgId = @@IDENTITY;

EXEC usp_PhotographyPackage_Upsert
    @Id = 0,
    @PackageName = 'Platinum Package',
    @PackageDescription = 'Ultimate luxury photography experience',
    @BasePrice = 100000,
    @Currency = 'INR',
    @DurationHours = 12,
    @MaxGalleryImages = 1000,
    @MaxVideoDurationMinutes = 30,
    @IncludedRawFiles = 1,
    @IncludedAlbum = 1,
    @IncludedRetouching = 1,
    @RetouchingLevel = 'Elite',
    @IncludedSecondPhotographer = 1,
    @IsActive = 1,
    @IsFeatured = 1,
    @DisplayOrder = 3,
    @CreatedBy = @AdminUserId,
    @UpdatedBy = @AdminUserId;

SELECT @PlatinumPkgId = @@IDENTITY;

PRINT 'Packages seeded: Silver=' + CAST(@SilverPkgId AS VARCHAR) + ', Gold=' + CAST(@GoldPkgId AS VARCHAR) + ', Platinum=' + CAST(@PlatinumPkgId AS VARCHAR);

-- ============================================
-- SEED PACKAGE ADD-ONS
-- ============================================

PRINT '=== Seeding Package Add-Ons ===';

EXEC usp_PackageAddOn_Upsert
    @Id = 0,
    @PackageId = @SilverPkgId,
    @AddOnName = 'Extra Hours',
    @AddOnDescription = 'Add 2 extra hours of photography',
    @Price = 5000,
    @Category = 'Time',
    @MaxQuantity = 3,
    @IsFeatured = 1,
    @DisplayOrder = 1,
    @IsActive = 1;

EXEC usp_PackageAddOn_Upsert
    @Id = 0,
    @PackageId = @GoldPkgId,
    @AddOnName = 'Drone Photography',
    @AddOnDescription = 'Aerial photography with drone',
    @Price = 15000,
    @Category = 'Special',
    @MaxQuantity = 1,
    @IsFeatured = 1,
    @DisplayOrder = 1,
    @IsActive = 1;

EXEC usp_PackageAddOn_Upsert
    @Id = 0,
    @PackageId = @PlatinumPkgId,
    @AddOnName = 'Same Day Edit Video',
    @AddOnDescription = 'Edited wedding video within 24 hours',
    @Price = 25000,
    @Category = 'Video',
    @MaxQuantity = 1,
    @IsFeatured = 1,
    @DisplayOrder = 1,
    @IsActive = 1;

PRINT 'Package add-ons seeded successfully';

-- ============================================
-- SEED PACKAGE DISCOUNTS
-- ============================================

PRINT '=== Seeding Package Discounts ===';

EXEC usp_PackageDiscount_Upsert
    @Id = 0,
    @PackageId = @GoldPkgId,
    @DiscountName = 'Early Bird Discount',
    @DiscountType = 'Percentage',
    @DiscountValue = 10,
    @ValidFrom = GETUTCDATE(),
    @ValidTo = DATEADD(DAY, 30, GETUTCDATE()),
    @IsActive = 1;

EXEC usp_PackageDiscount_Upsert
    @Id = 0,
    @PackageId = @PlatinumPkgId,
    @DiscountName = 'Referral Discount',
    @DiscountType = 'Fixed',
    @DiscountValue = 5000,
    @ValidFrom = GETUTCDATE(),
    @ValidTo = NULL,
    @IsActive = 1;

PRINT 'Package discounts seeded successfully';

-- ============================================
-- SEED CAMPAIGNS & OFFERS
-- ============================================

PRINT '=== Seeding Campaigns & Current Offers ===';

EXEC usp_Campaign_Upsert
    @Id = 0,
    @CampaignName = 'Summer Wedding Special',
    @Description = 'Get 20% off on all wedding packages this summer. Perfect for outdoor celebrations!',
    @CampaignType = 'Wedding',
    @StartDate = DATEADD(DAY, -5, GETUTCDATE()),
    @EndDate = DATEADD(DAY, 60, GETUTCDATE()),
    @BannerImageUrl = '/assets/campaigns/summer-wedding-special.webp',
    @DiscountType = 'Percentage',
    @DiscountValue = 20,
    @MaxApplicableAmount = NULL,
    @TermsConditions = 'Valid on Gold and Platinum packages. Cannot be combined with other offers.',
    @IsActive = 1,
    @DisplayOrder = 1,
    @CreatedBy = @AdminUserId,
    @UpdatedBy = @AdminUserId;

EXEC usp_Campaign_Upsert
    @Id = 0,
    @CampaignName = 'Monsoon Portrait Sessions',
    @Description = 'Get a free family portrait session with every Gold package booking!',
    @CampaignType = 'Portrait',
    @StartDate = DATEADD(DAY, -10, GETUTCDATE()),
    @EndDate = DATEADD(DAY, 45, GETUTCDATE()),
    @BannerImageUrl = '/assets/campaigns/monsoon-portrait.webp',
    @DiscountType = 'BOGO',
    @DiscountValue = 5000,
    @MaxApplicableAmount = NULL,
    @TermsConditions = 'One free portrait session per booking. Session must be scheduled within 3 months.',
    @IsActive = 1,
    @DisplayOrder = 2,
    @CreatedBy = @AdminUserId,
    @UpdatedBy = @AdminUserId;

EXEC usp_Campaign_Upsert
    @Id = 0,
    @CampaignName = 'Referral Bonanza',
    @Description = 'Refer a friend and get flat ₹7,500 discount on your next booking!',
    @CampaignType = 'Loyalty',
    @StartDate = GETUTCDATE(),
    @EndDate = DATEADD(DAY, 90, GETUTCDATE()),
    @BannerImageUrl = '/assets/campaigns/referral-bonus.webp',
    @DiscountType = 'Fixed',
    @DiscountValue = 7500,
    @MaxApplicableAmount = 100000,
    @TermsConditions = 'Valid for referred clients. Must complete booking to receive discount.',
    @IsActive = 1,
    @DisplayOrder = 3,
    @CreatedBy = @AdminUserId,
    @UpdatedBy = @AdminUserId;

EXEC usp_Campaign_Upsert
    @Id = 0,
    @CampaignName = 'Free Drone Photography',
    @Description = 'Add drone photography for free when booking Platinum package!',
    @CampaignType = 'Special',
    @StartDate = DATEADD(DAY, -2, GETUTCDATE()),
    @EndDate = DATEADD(DAY, 30, GETUTCDATE()),
    @BannerImageUrl = '/assets/campaigns/free-drone.webp',
    @DiscountType = 'FreeAddon',
    @DiscountValue = 15000,
    @MaxApplicableAmount = NULL,
    @TermsConditions = 'Only for Platinum package bookings. Weather dependent.',
    @IsActive = 1,
    @DisplayOrder = 4,
    @CreatedBy = @AdminUserId,
    @UpdatedBy = @AdminUserId;

PRINT 'Campaigns and offers seeded successfully';

-- ============================================
-- SEED CLIENT INFO
-- ============================================

PRINT '=== Seeding Sample Clients ===';

DECLARE @Client1Id INT, @Client2Id INT;

EXEC usp_ClientInfo_Upsert
    @Id = 0,
    @Email = 'client1@example.com',
    @Phone = '+91-8765432109',
    @FullName = 'Rajesh Kumar',
    @Address = '456 Wedding Lane, City, India 560001',
    @PreferredContactMethod = 'Phone';

SELECT @Client1Id = @@IDENTITY;

EXEC usp_ClientInfo_Upsert
    @Id = 0,
    @Email = 'client2@example.com',
    @Phone = '+91-9012345678',
    @FullName = 'Priya Singh',
    @Address = '789 Event Street, City, India 560002',
    @PreferredContactMethod = 'Email';

SELECT @Client2Id = @@IDENTITY;

PRINT 'Sample clients seeded: Client1=' + CAST(@Client1Id AS VARCHAR) + ', Client2=' + CAST(@Client2Id AS VARCHAR);

-- ============================================
-- SEED AVAILABILITY
-- ============================================

PRINT '=== Seeding Availability Windows ===';

DECLARE @Today DATETIME = CAST(GETUTCDATE() AS DATE);

-- Seed availability windows for photographers
DECLARE @PhotographerId INT = 2; -- Photographer user ID
EXEC usp_Availability_Upsert
    @Id = 0,
    @PhotographerUserID = @PhotographerId,
    @AvailabilityStart = @Today,
    @AvailabilityEnd = DATEADD(DAY, 90, @Today),
    @IsAvailable = 1,
    @Notes = 'Q2 2026 booking window for photographer';

PRINT 'Availability windows seeded successfully';

-- ============================================
-- VERIFICATION
-- ============================================

PRINT '';
PRINT '=== SEED DATA VERIFICATION ===';
PRINT '';

PRINT '=== Roles ===';
SELECT * FROM Roles;

PRINT '=== Users ===';
SELECT UserID, Email, FullName, IsActive FROM Users;

PRINT '=== User Roles ===';
SELECT ur.UserRoleID, u.FullName, r.RoleName
FROM UserRoles ur
INNER JOIN Users u ON ur.UserID = u.UserID
INNER JOIN Roles r ON ur.RoleID = r.RoleID;

PRINT '=== Gallery Types ===';
SELECT * FROM GalleryType;

PRINT '=== Galleries ===';
SELECT g.GalleryID, g.Title, gt.TypeName, g.DisplayOrder, g.IsFeatured, g.IsPublished
FROM Gallery g
INNER JOIN GalleryType gt ON g.GalleryTypeID = gt.GalleryTypeID;

PRINT '=== Gallery Assets ===';
SELECT ga.AssetID, g.Title, ga.AssetType, ga.MediaUrl, ga.DisplayOrder
FROM GalleryAsset ga
INNER JOIN Gallery g ON ga.GalleryID = g.GalleryID;

PRINT '=== Asset Count by Gallery ===';
SELECT g.Title, COUNT(ga.AssetID) AS AssetCount
FROM Gallery g
LEFT JOIN GalleryAsset ga ON g.GalleryID = ga.GalleryID
GROUP BY g.Title;

PRINT '=== Photography Packages ===';
SELECT PackageID, PackageName, BasePrice, IsActive, IsFeatured, DisplayOrder FROM PhotographyPackage;

PRINT '=== Package Add-Ons ===';
SELECT pa.AddOnID, p.PackageName, pa.AddOnName, pa.Price, pa.IsActive
FROM PackageAddOn pa
INNER JOIN PhotographyPackage p ON pa.PackageID = p.PackageID;

PRINT '=== Package Discounts ===';
SELECT pd.DiscountID, p.PackageName, pd.DiscountName, pd.DiscountType, pd.DiscountValue
FROM PackageDiscount pd
INNER JOIN PhotographyPackage p ON pd.PackageID = p.PackageID;

PRINT '=== Settings ===';
SELECT SettingKey, SettingValue FROM Settings;

PRINT '';
PRINT '=== SEED DATA COMPLETE ===';
PRINT 'All initial data has been successfully seeded using stored procedures.';

-- ============================================
-- SEED ASSET DATA
-- ============================================

PRINT '';
PRINT '=== SEEDING ASSET DATA ===';

-- Sample Assets (Gallery Images/Videos, Booking documents, Invoice receipts, etc.)
EXEC usp_Asset_Upsert 
    @Id = 0,
    @AssetType = 'Image',
    @EntityType = 'Gallery',
    @EntityID = 1,
    @FilePath = '/assets/galleries/wedding-2024/photo-001.webp',
    @FileName = 'photo-001.webp',
    @FileSize = 2457600,
    @MimeType = 'image/webp',
    @Description = 'Wedding ceremony close-up',
    @UploadedByUserID = 2;

EXEC usp_Asset_Upsert 
    @Id = 0,
    @AssetType = 'Image',
    @EntityType = 'Gallery',
    @EntityID = 1,
    @FilePath = '/assets/galleries/wedding-2024/photo-002.webp',
    @FileName = 'photo-002.webp',
    @FileSize = 2816000,
    @MimeType = 'image/webp',
    @Description = 'Reception dance floor',
    @UploadedByUserID = 2;

EXEC usp_Asset_Upsert 
    @Id = 0,
    @AssetType = 'Video',
    @EntityType = 'Gallery',
    @EntityID = 2,
    @FilePath = '/assets/galleries/corporate-2024/video-001.mp4',
    @FileName = 'video-001.mp4',
    @FileSize = 157286400,
    @MimeType = 'video/mp4',
    @Description = 'Company event highlight reel',
    @UploadedByUserID = 2;

EXEC usp_Asset_Upsert 
    @Id = 0,
    @AssetType = 'Document',
    @EntityType = 'Booking',
    @EntityID = 1,
    @FilePath = '/assets/documents/booking-001-contract.pdf',
    @FileName = 'booking-001-contract.pdf',
    @FileSize = 512000,
    @MimeType = 'application/pdf',
    @Description = 'Signed booking contract',
    @UploadedByUserID = 1;

-- ============================================
-- SEED EXPENSE DATA
-- ============================================

PRINT '';
PRINT '=== SEEDING EXPENSE DATA ===';

-- Sample Expenses
EXEC usp_Expense_Upsert
    @Id = 0,
    @BookingID = 1,
    @EventID = NULL,
    @ExpenseType = 'Travel',
    @Description = 'Rental car for wedding day',
    @Amount = 150.00,
    @Currency = 'USD',
    @Status = 'Approved',
    @ReceiptAssetID = NULL,
    @CreatedByUserID = 2,
    @ApprovedByUserID = 1,
    @ApprovedDate = GETUTCDATE();

EXEC usp_Expense_Upsert
    @Id = 0,
    @BookingID = 1,
    @EventID = NULL,
    @ExpenseType = 'Equipment',
    @Description = 'Backup lens rental',
    @Amount = 75.50,
    @Currency = 'USD',
    @Status = 'Approved',
    @ReceiptAssetID = NULL,
    @CreatedByUserID = 2,
    @ApprovedByUserID = 1,
    @ApprovedDate = GETUTCDATE();

EXEC usp_Expense_Upsert
    @Id = 0,
    @BookingID = 2,
    @EventID = NULL,
    @ExpenseType = 'Crew',
    @Description = 'Assistant photographer',
    @Amount = 300.00,
    @Currency = 'USD',
    @Status = 'Pending',
    @ReceiptAssetID = NULL,
    @CreatedByUserID = 2,
    @ApprovedByUserID = NULL,
    @ApprovedDate = NULL;

EXEC usp_Expense_Upsert
    @Id = 0,
    @BookingID = NULL,
    @EventID = 1,
    @ExpenseType = 'Other',
    @Description = 'Studio rent for editing suite',
    @Amount = 500.00,
    @Currency = 'USD',
    @Status = 'Paid',
    @ReceiptAssetID = NULL,
    @CreatedByUserID = 2,
    @ApprovedByUserID = 1,
    @ApprovedDate = GETUTCDATE();

PRINT '';
PRINT '=== Asset & Expense Seed Data Complete ===';

-- ============================================
-- CAMPAIGN PACKAGE SEED DATA (Phase 2)
-- ============================================

PRINT '';
PRINT '=== Campaign Package Seed Data ===';

EXEC usp_CampaignPackage_Upsert
    @Id = 0,
    @CampaignID = 1,  -- Summer Wedding Special
    @PackageID = 1,   -- Premium Wedding
    @IsApplicable = 1;

EXEC usp_CampaignPackage_Upsert
    @Id = 0,
    @CampaignID = 2,  -- Monsoon Portrait Sessions
    @PackageID = 2,   -- Standard Portrait
    @IsApplicable = 1;

EXEC usp_CampaignPackage_Upsert
    @Id = 0,
    @CampaignID = 3,  -- Referral Bonanza
    @PackageID = 1,   -- Premium Wedding
    @IsApplicable = 1;

EXEC usp_CampaignPackage_Upsert
    @Id = 0,
    @CampaignID = 3,  -- Referral Bonanza
    @PackageID = 2,   -- Standard Portrait
    @IsApplicable = 1;

EXEC usp_CampaignPackage_Upsert
    @Id = 0,
    @CampaignID = 4,  -- Free Drone Photography
    @PackageID = 1,   -- Premium Wedding (most applicable)
    @IsApplicable = 1;

PRINT 'Campaign Package mappings created: 5 package-campaign links';

-- ============================================
-- QUOTATION ENGAGEMENT TRACKING (HIGH Gap #8)
-- ============================================

PRINT '';
PRINT '=== Seeding Quotation Engagement Tracking ===';

-- Quotations with various engagement states
INSERT INTO Quotation (EventID, ClientEmail, ClientName, QuotationNumber, QuotationDate, ValidUntil, SubTotal, TaxAmount, TotalAmount, Status, Notes, ViewedAt, AcceptedAt, DeclinedAt, RejectionReason, CreatedBy, UpdatedBy, IsDeleted)
VALUES
(1, 'client1@example.com', 'John Smith', 'QT-2024-001', '2024-04-01', '2024-04-15', 1000.00, 100.00, 1100.00, 'Accepted', 'Premium wedding package', '2024-04-02', '2024-04-03', NULL, NULL, 1, 1, 0),
(2, 'client2@example.com', 'Jane Doe', 'QT-2024-002', '2024-04-05', '2024-04-20', 500.00, 50.00, 550.00, 'Rejected', 'Basic portrait session', '2024-04-06', NULL, '2024-04-08', 'Out of budget', 1, NULL, 0),
(3, 'client3@example.com', 'Michael Chen', 'QT-2024-003', '2024-04-10', '2024-04-25', 1500.00, 150.00, 1650.00, 'Draft', 'Corporate event coverage', NULL, NULL, NULL, NULL, 1, NULL, 0),
(4, 'client4@example.com', 'Sarah Wilson', 'QT-2024-004', '2024-04-12', '2024-04-27', 800.00, 80.00, 880.00, 'Sent', 'Family session', '2024-04-12', NULL, NULL, NULL, 1, NULL, 0);

PRINT 'Quotation engagement tracking seeded: 4 quotations with various states (Accepted, Rejected, Draft, Sent)';

-- ============================================
-- PHOTOGRAPHER PROFILE DATA (HIGH Gap #9)
-- ============================================

PRINT '';
PRINT '=== Seeding Photographer Profile Data ===';

-- Update existing users with photographer info
UPDATE Users
SET IsPhotographer = 1,
    HourlyRate = 150.00,
    DailyRate = 1200.00,
    MaxBookingsPerMonth = 15,
    PreferredWorkingHours = '9am-6pm, Weekdays preferred'
WHERE Email = 'admin@smartworkz.com';

UPDATE Users
SET IsPhotographer = 1,
    HourlyRate = 120.00,
    DailyRate = 950.00,
    MaxBookingsPerMonth = 12,
    PreferredWorkingHours = 'Flexible, Available weekends'
WHERE Email IN (SELECT Email FROM Users WHERE UserID > 1 LIMIT 1);

-- Verify Users have photographer fields populated
PRINT 'Photographer profile data seeded: Users updated with HourlyRate, DailyRate, MaxBookingsPerMonth, PreferredWorkingHours';

-- ============================================
-- LOCATION-BASED PRICING (HIGH Gap #10)
-- ============================================

PRINT '';
PRINT '=== Seeding Location-Based Pricing ===';

-- Sample location fees for different cities
INSERT INTO LocationFee (LocationName, City, State, ZipCode, TravelMinutes, SurchargeAmount, SurchargeType, IsActive, CreatedBy, CreatedAt)
VALUES
('Downtown Studio', 'New York', 'NY', '10001', 0, 0.00, 'Flat', 1, 1, GETUTCDATE()),
('Midtown Manhattan', 'New York', 'NY', '10022', 15, 150.00, 'Flat', 1, 1, GETUTCDATE()),
('Brooklyn Venue', 'Brooklyn', 'NY', '11201', 30, 200.00, 'Flat', 1, 1, GETUTCDATE()),
('Queens Event Space', 'Queens', 'NY', '11375', 45, 250.00, 'Flat', 1, 1, GETUTCDATE()),
('Westchester Hotel', 'White Plains', 'NY', '10601', 60, 300.00, 'Flat', 1, 1, GETUTCDATE()),
('Beach Wedding Venue', 'East Hampton', 'NY', '11937', 90, 500.00, 'Flat', 1, 1, GETUTCDATE()),
('Suburban Venue', 'Jersey City', 'NJ', '07302', 40, 200.00, 'Flat', 1, 1, GETUTCDATE());

PRINT 'Location-based pricing seeded: 7 locations with surcharge amounts ranging from $0 to $500';

-- ============================================
-- RENTAL CLIENT SEED DATA (Phase 3)
-- ============================================

PRINT '';
PRINT '=== Equipment Rental Client Seed Data ===';

EXEC usp_RentalClient_Upsert
    @Id = 0,
    @Email = 'filmmaker.pro@example.com',
    @Phone = '+1-555-1001',
    @FullName = 'Jane Smith',
    @Address = '456 Oak Ave',
    @City = 'Los Angeles',
    @State = 'CA',
    @ZipCode = '90001',
    @ProfilePhotoUrl = '/assets/rental-clients/jane-smith.jpg',
    @ValidIDType = 'DriverLicense',
    @ValidIDNumber = 'DL987654321',
    @ValidIDPhotoUrl = '/assets/rental-clients/jane-smith-id.jpg',
    @ValidIDExpiry = '2028-03-20',
    @PreferredContactMethod = 'Email';

EXEC usp_RentalClient_Upsert
    @Id = 0,
    @Email = 'videographer.creative@example.com',
    @Phone = '+1-555-1002',
    @FullName = 'Michael Chen',
    @Address = '789 Pine St',
    @City = 'San Francisco',
    @State = 'CA',
    @ZipCode = '94102',
    @ProfilePhotoUrl = '/assets/rental-clients/michael-chen.jpg',
    @ValidIDType = 'Passport',
    @ValidIDNumber = 'PP123456789',
    @ValidIDPhotoUrl = '/assets/rental-clients/michael-chen-id.jpg',
    @ValidIDExpiry = '2027-11-15',
    @PreferredContactMethod = 'Phone';

EXEC usp_RentalClient_Upsert
    @Id = 0,
    @Email = 'production.house@example.com',
    @Phone = '+1-555-1003',
    @FullName = 'Production House Team',
    @Address = '321 Main Blvd',
    @City = 'New York',
    @State = 'NY',
    @ZipCode = '10001',
    @ProfilePhotoUrl = '/assets/rental-clients/production-house.jpg',
    @ValidIDType = 'NationalID',
    @ValidIDNumber = 'NID-2024-001',
    @ValidIDPhotoUrl = '/assets/rental-clients/production-house-id.jpg',
    @ValidIDExpiry = '2029-06-30',
    @PreferredContactMethod = 'Email';

-- Verify IDs for first 2 clients
UPDATE RentalClient
SET IsIDVerified = 1, IDVerifiedBy = 2, IDVerifiedAt = GETUTCDATE()
WHERE Email IN ('filmmaker.pro@example.com', 'videographer.creative@example.com');

PRINT 'Created 3 rental clients: Jane Smith, Michael Chen, Production House Team';

-- ============================================
-- RENTAL AGREEMENT SEED DATA (Phase 3)
-- ============================================

PRINT '';
PRINT '=== Equipment Rental Agreement Seed Data ===';

EXEC usp_RentalAgreement_Upsert
    @Id = 0,
    @RentalClientID = 1,              -- Jane Smith
    @EquipmentID = 5,                 -- DJI Air 3 Drone
    @RentalStartDate = '2026-05-01',
    @RentalEndDate = '2026-05-05',
    @RentalRate = 150.00,
    @RentalCost = 600.00,             -- 4 days × $150
    @SecurityDeposit = 500.00,
    @InsuranceRequired = 1,
    @InsuranceType = 'EquipmentDamage',
    @InsuranceCost = 100.00,
    @MaxDamageDeductible = 100.00,
    @EquipmentConditionOnHandover = 'Excellent',
    @CreatedBy = 2;                   -- Admin creates

EXEC usp_RentalAgreement_Upsert
    @Id = 0,
    @RentalClientID = 2,              -- Michael Chen
    @EquipmentID = 4,                 -- Lighting Kit (from Equipment table)
    @RentalStartDate = '2026-05-10',
    @RentalEndDate = '2026-05-13',
    @RentalRate = 75.00,
    @RentalCost = 225.00,             -- 3 days × $75
    @SecurityDeposit = 300.00,
    @InsuranceRequired = 1,
    @InsuranceType = 'EquipmentDamage',
    @InsuranceCost = 50.00,
    @MaxDamageDeductible = 75.00,
    @EquipmentConditionOnHandover = 'Excellent',
    @CreatedBy = 2;

EXEC usp_RentalAgreement_Upsert
    @Id = 0,
    @RentalClientID = 3,              -- Production House Team
    @EquipmentID = 5,                 -- DJI Air 3 Drone (different dates)
    @RentalStartDate = '2026-05-20',
    @RentalEndDate = '2026-05-27',
    @RentalRate = 140.00,             -- Weekly discount rate
    @RentalCost = 980.00,             -- 7 days × $140
    @SecurityDeposit = 500.00,
    @InsuranceRequired = 1,
    @InsuranceType = 'FullCoverage',
    @InsuranceCost = 150.00,
    @MaxDamageDeductible = 200.00,
    @EquipmentConditionOnHandover = 'Good',
    @CreatedBy = 2;

PRINT 'Created 3 rental agreements for equipment rental';

-- Accept terms for first agreement
UPDATE RentalAgreement
SET TermsAccepted = 1, TermsAcceptedDate = GETUTCDATE(),
    SignatureUrl = '/assets/rental-agreements/1-signature.png', Status = 'Active'
WHERE RentalAgreementID = 1;

PRINT 'Jane Smith accepted rental terms - Agreement 1 is now ACTIVE';

-- ============================================
-- RENTAL AGREEMENT DOCUMENTS SEED DATA
-- ============================================

PRINT '';
PRINT '=== Rental Agreement Documents Seed Data ===';

INSERT INTO RentalAgreementDocument (RentalAgreementID, DocumentType, DocumentUrl, UploadedBy, UploadedAt)
VALUES
    (1, 'Agreement', '/assets/rental-agreements/1-agreement.pdf', 2, GETUTCDATE()),
    (1, 'IDVerification', '/assets/rental-agreements/1-id-verified.pdf', 2, GETUTCDATE()),
    (1, 'Signature', '/assets/rental-agreements/1-signature.png', 2, GETUTCDATE());

INSERT INTO RentalAgreementDocument (RentalAgreementID, DocumentType, DocumentUrl, UploadedBy, UploadedAt)
VALUES
    (2, 'Agreement', '/assets/rental-agreements/2-agreement.pdf', 2, GETUTCDATE()),
    (2, 'IDVerification', '/assets/rental-agreements/2-id-verified.pdf', 2, GETUTCDATE());

PRINT 'Created 5 rental agreement documents';

-- ============================================
-- RENTAL RETURN INSPECTION SEED DATA
-- ============================================

PRINT '';
PRINT '=== Rental Return Inspection Seed Data ===';

-- Simulate Jane Smith returning the drone after rental
EXEC usp_RentalReturnInspection_Upsert
    @Id = 0,
    @RentalAgreementID = 1,
    @InspectedBy = 2,                -- Admin inspector
    @OverallCondition = 'Excellent',
    @HasDamage = 0,
    @DamageDescription = NULL,
    @PhotoUrl = NULL,
    @EstimatedRepairCost = 0,
    @IsFunctional = 1,
    @TestNotes = 'All systems functional, battery life excellent, no visible damage',
    @ApprovedBy = 2;                 -- Admin approves return

-- Update rental agreement to mark as returned
UPDATE RentalAgreement
SET Status = 'Returned', PaymentStatus = 'Paid', ReturnedAt = GETUTCDATE(),
    EquipmentConditionOnReturn = 'Excellent', DepositReturnedDate = GETUTCDATE()
WHERE RentalAgreementID = 1;

-- Release equipment from rental
UPDATE Equipment
SET IsCurrentlyRented = 0, CurrentRentalEndDate = NULL
WHERE EquipmentID = 5 AND IsCurrentlyRented = 1;

PRINT 'Jane Smith returned drone - Inspection complete, deposit refunded';

-- ============================================
-- RENTAL BUSINESS METRICS
-- ============================================

PRINT '';
PRINT '=== Equipment Rental Summary ===';
PRINT 'Total Rental Clients: 3';
PRINT 'Total Rental Agreements: 3';
PRINT 'Active Rentals: 2 (Jane Smith returned, Michael Chen & Production House still active)';
PRINT 'Total Rental Revenue (Agreements): $1,805.00';
PRINT 'Total Security Deposits Held: $1,300.00';
PRINT 'Total Insurance Revenue: $300.00';
PRINT '';
PRINT '=== All Phase 3 Equipment Rental Data Complete ===';

-- ============================================
-- POPULATE NEW COLUMN VALUES (Phase 4)
-- ============================================

PRINT '';
PRINT '=== Populating New Column Values ===';

-- ============================================
-- 1. ClientInfo: CreatedBy & UpdatedBy
-- ============================================

PRINT '';
PRINT '--- Updating ClientInfo with CreatedBy & UpdatedBy ---';

UPDATE ClientInfo
SET CreatedBy = @AdminUserId,
    UpdatedBy = @AdminUserId
WHERE CreatedBy IS NULL OR UpdatedBy IS NULL;

PRINT 'ClientInfo records updated with CreatedBy=' + CAST(@AdminUserId AS VARCHAR) + ', UpdatedBy=' + CAST(@AdminUserId AS VARCHAR);

-- ============================================
-- 2. Gallery: ReviewStatus, ClientApprovalDeadline, ApprovedByUserID
-- ============================================

PRINT '';
PRINT '--- Updating Gallery with ReviewStatus & Approval Data ---';

-- Set Wedding gallery as approved
UPDATE Gallery
SET ReviewStatus = 'ApprovedByClient',
    ClientApprovalDeadline = DATEADD(DAY, 14, CreatedAt),
    ApprovedByUserID = @AdminUserId
WHERE GalleryID = @WeddingGalleryId;

-- Set Portrait gallery as approved
UPDATE Gallery
SET ReviewStatus = 'ApprovedByClient',
    ClientApprovalDeadline = DATEADD(DAY, 14, CreatedAt),
    ApprovedByUserID = @AdminUserId
WHERE GalleryID = @PortraitGalleryId;

-- Set Corporate gallery as under review (pending approval)
UPDATE Gallery
SET ReviewStatus = 'UnderReview',
    ClientApprovalDeadline = DATEADD(DAY, 14, CreatedAt)
WHERE GalleryID = @CorporateGalleryId;

-- Set Video galleries as draft
UPDATE Gallery
SET ReviewStatus = 'Draft',
    ClientApprovalDeadline = DATEADD(DAY, 14, CreatedAt)
WHERE GalleryTypeID = @VideoGalleryTypeId;

-- Set Slider as ready for delivery
UPDATE Gallery
SET ReviewStatus = 'ReadyForDelivery',
    ClientApprovalDeadline = DATEADD(DAY, 14, CreatedAt),
    ApprovedByUserID = @AdminUserId
WHERE GalleryID = @SliderId;

PRINT 'Gallery records updated with ReviewStatus and approval data';

-- ============================================
-- 3. GalleryAsset: AssetStatus & RetouchNotes
-- ============================================

PRINT '';
PRINT '--- Updating GalleryAsset with AssetStatus & RetouchNotes ---';

-- Mark wedding photos as original (first 3)
UPDATE GalleryAsset
SET AssetStatus = 'Original',
    RetouchNotes = NULL
WHERE AssetID IN (1, 2, 3);

-- Mark portrait photos as retouched
UPDATE GalleryAsset
SET AssetStatus = 'Retouched',
    RetouchNotes = 'Color corrected, skin tone adjusted, blemishes removed'
WHERE AssetID IN (4, 5);

-- Mark videos as final
UPDATE GalleryAsset
SET AssetStatus = 'Final',
    RetouchNotes = 'Edited and color graded, ready for delivery'
WHERE AssetType = 'Video';

-- Mark slider images as final
UPDATE GalleryAsset
SET AssetStatus = 'Final',
    RetouchNotes = 'Optimized for web, color corrected'
WHERE AssetType = 'Slide';

-- Set default AssetStatus for any remaining assets
UPDATE GalleryAsset
SET AssetStatus = 'Original'
WHERE AssetStatus IS NULL;

PRINT 'GalleryAsset records updated with AssetStatus and RetouchNotes';

-- ============================================
-- 4. Event: EventType
-- ============================================

PRINT '';
PRINT '--- Updating Event with EventType ---';

-- Default all events to 'Other' if not already set (as fallback)
UPDATE Event
SET EventType = 'Other'
WHERE EventType IS NULL;

PRINT 'Event records updated with EventType (defaulted to Other for any without type)';

-- ============================================
-- 5. PhotographyPackage: ServiceCategory
-- ============================================

PRINT '';
PRINT '--- Updating PhotographyPackage with ServiceCategory ---';

-- Update existing packages with appropriate categories
UPDATE PhotographyPackage
SET ServiceCategory = 'Wedding'
WHERE PackageID = @SilverPkgId;

UPDATE PhotographyPackage
SET ServiceCategory = 'Wedding'
WHERE PackageID = @GoldPkgId;

UPDATE PhotographyPackage
SET ServiceCategory = 'Wedding'
WHERE PackageID = @PlatinumPkgId;

-- Set default for any remaining packages
UPDATE PhotographyPackage
SET ServiceCategory = 'Other'
WHERE ServiceCategory IS NULL;

PRINT 'PhotographyPackage records updated with ServiceCategory';

-- ============================================
-- 6. PaymentMethod: Seed Payment Methods (if not already seeded)
-- ============================================

PRINT '';
PRINT '--- Seeding Payment Methods ---';

IF NOT EXISTS (SELECT 1 FROM PaymentMethod WHERE MethodName = 'Credit Card')
BEGIN
    INSERT INTO PaymentMethod (MethodName, IsActive) VALUES ('Credit Card', 1);
    INSERT INTO PaymentMethod (MethodName, IsActive) VALUES ('Debit Card', 1);
    INSERT INTO PaymentMethod (MethodName, IsActive) VALUES ('Bank Transfer', 1);
    INSERT INTO PaymentMethod (MethodName, IsActive) VALUES ('Wire Transfer', 1);
    INSERT INTO PaymentMethod (MethodName, IsActive) VALUES ('Check', 1);
    INSERT INTO PaymentMethod (MethodName, IsActive) VALUES ('Cash', 1);
    INSERT INTO PaymentMethod (MethodName, IsActive) VALUES ('PayPal', 1);
    INSERT INTO PaymentMethod (MethodName, IsActive) VALUES ('Stripe', 1);
    INSERT INTO PaymentMethod (MethodName, IsActive) VALUES ('Square', 1);
    INSERT INTO PaymentMethod (MethodName, IsActive) VALUES ('Other', 1);
    PRINT 'Payment Methods seeded: 10 methods created';
END
ELSE
BEGIN
    PRINT 'Payment Methods already exist, skipping insertion';
END

-- ============================================
-- 7. Booking: DepositAmount & DepositPaid
-- ============================================

PRINT '';
PRINT '--- Updating Booking with DepositAmount & DepositPaid ---';

-- Calculate deposit as 50% of TotalPrice and mark as paid for all bookings
UPDATE Booking
SET DepositAmount = ROUND(TotalPrice * 0.5, 2),
    DepositPaid = 1
WHERE DepositAmount IS NULL;

-- Set default deposit to 0 for any remaining records
UPDATE Booking
SET DepositAmount = COALESCE(DepositAmount, 0),
    DepositPaid = COALESCE(DepositPaid, 0)
WHERE DepositAmount IS NULL OR DepositPaid IS NULL;

PRINT 'Booking records updated with DepositAmount (50% of TotalPrice) and DepositPaid=1';

-- ============================================
-- 8. BookingPackage: CampaignID (Optional)
-- ============================================

PRINT '';
PRINT '--- Updating BookingPackage with CampaignID ---';

-- Link some booking packages to campaigns (optional)
-- This assumes campaign IDs 1-4 exist from earlier seeding
-- Leaving CampaignID as NULL for others (no campaign)

PRINT 'BookingPackage records ready for optional CampaignID linking (NULL by default)';

-- ============================================
-- VERIFICATION OF NEW COLUMN POPULATION
-- ============================================

PRINT '';
PRINT '=== VERIFICATION: New Column Population ===';
PRINT '';

PRINT '--- ClientInfo: CreatedBy & UpdatedBy ---';
SELECT TOP 5 ClientID, FullName, CreatedBy, UpdatedBy FROM ClientInfo;

PRINT '';
PRINT '--- Gallery: ReviewStatus, ClientApprovalDeadline, ApprovedByUserID ---';
SELECT TOP 5 GalleryID, Title, ReviewStatus, ClientApprovalDeadline, ApprovedByUserID FROM Gallery;

PRINT '';
PRINT '--- GalleryAsset: AssetStatus & RetouchNotes ---';
SELECT TOP 5 AssetID, AssetType, AssetStatus, RetouchNotes FROM GalleryAsset;

PRINT '';
PRINT '--- Event: EventType ---';
SELECT TOP 5 EventID, EventName, EventType FROM Event;

PRINT '';
PRINT '--- PhotographyPackage: ServiceCategory ---';
SELECT TOP 5 PackageID, PackageName, ServiceCategory FROM PhotographyPackage;

PRINT '';
PRINT '--- PaymentMethod: Available Methods ---';
SELECT PaymentMethodID, MethodName, IsActive FROM PaymentMethod;

PRINT '';
PRINT '--- Booking: DepositAmount & DepositPaid ---';
SELECT TOP 5 BookingID, TotalPrice, DepositAmount, DepositPaid FROM Booking;

PRINT '';
PRINT '=== All New Column Values Successfully Populated ===';

-- ============================================
-- SOFT-DELETE AUDIT TRAIL (All Tables)
-- ============================================

PRINT '';
PRINT '=== Seeding Soft-Delete Audit Columns ===';

-- Table 1: Event
PRINT '--- Updating Event ---';
UPDATE Event SET CreatedBy = 1, UpdatedBy = NULL, DeletedBy = NULL, DeletedAt = NULL, IsDeleted = 0 WHERE EventID > 0;
PRINT 'Event: Audit columns populated';

-- Table 2: Gallery
PRINT '--- Updating Gallery ---';
UPDATE Gallery SET CreatedBy = 1, UpdatedBy = NULL, DeletedBy = NULL, DeletedAt = NULL, IsDeleted = 0 WHERE GalleryID > 0;
PRINT 'Gallery: Audit columns populated';

-- Table 3: GalleryAsset
PRINT '--- Updating GalleryAsset ---';
UPDATE GalleryAsset SET CreatedBy = 1, DeletedBy = NULL, DeletedAt = NULL, IsDeleted = 0 WHERE AssetID > 0;
PRINT 'GalleryAsset: Audit columns populated';

-- Table 4: GalleryAccess
PRINT '--- Updating GalleryAccess ---';
UPDATE GalleryAccess SET CreatedBy = 1, DeletedBy = NULL, DeletedAt = NULL, IsDeleted = 0 WHERE AccessID > 0;
PRINT 'GalleryAccess: Audit columns populated';

-- Table 5: PhotographyPackage
PRINT '--- Updating PhotographyPackage ---';
UPDATE PhotographyPackage SET CreatedBy = 1, UpdatedBy = NULL, DeletedBy = NULL, DeletedAt = NULL, IsDeleted = 0 WHERE PackageID > 0;
PRINT 'PhotographyPackage: Audit columns populated';

-- Table 6: PackageComponent
PRINT '--- Updating PackageComponent ---';
UPDATE PackageComponent SET CreatedBy = 1, UpdatedBy = NULL, DeletedBy = NULL, DeletedAt = NULL, IsDeleted = 0 WHERE ComponentID > 0;
PRINT 'PackageComponent: Audit columns populated';

-- Table 7: PackageAddOn
PRINT '--- Updating PackageAddOn ---';
UPDATE PackageAddOn SET CreatedBy = 1, UpdatedBy = NULL, DeletedBy = NULL, DeletedAt = NULL, IsDeleted = 0 WHERE AddOnID > 0;
PRINT 'PackageAddOn: Audit columns populated';

-- Table 8: PackageDiscount
PRINT '--- Updating PackageDiscount ---';
UPDATE PackageDiscount SET CreatedBy = 1, UpdatedBy = NULL, DeletedBy = NULL, DeletedAt = NULL, IsDeleted = 0 WHERE DiscountID > 0;
PRINT 'PackageDiscount: Audit columns populated';

-- Table 9: Campaign
PRINT '--- Updating Campaign ---';
UPDATE Campaign SET CreatedBy = 1, UpdatedBy = NULL, DeletedBy = NULL, DeletedAt = NULL, IsDeleted = 0 WHERE CampaignID > 0;
PRINT 'Campaign: Audit columns populated';

-- Table 10: CampaignPackage
PRINT '--- Updating CampaignPackage ---';
UPDATE CampaignPackage SET CreatedBy = 1, DeletedBy = NULL, DeletedAt = NULL, IsDeleted = 0 WHERE CampaignPackageID > 0;
PRINT 'CampaignPackage: Audit columns populated';

-- Table 11: BookingPackage
PRINT '--- Updating BookingPackage ---';
UPDATE BookingPackage SET DeletedBy = NULL, DeletedAt = NULL, IsDeleted = 0 WHERE BookingPackageID > 0;
PRINT 'BookingPackage: Audit columns populated';

-- Table 12: CalendarBlock
PRINT '--- Updating CalendarBlock ---';
UPDATE CalendarBlock SET DeletedBy = NULL, DeletedAt = NULL, IsDeleted = 0 WHERE BlockID > 0;
PRINT 'CalendarBlock: Audit columns populated';

-- Table 13: Availability
PRINT '--- Updating Availability ---';
UPDATE Availability SET DeletedBy = NULL, DeletedAt = NULL, IsDeleted = 0 WHERE AvailabilityID > 0;
PRINT 'Availability: Audit columns populated';

-- Table 14: DailyTask
PRINT '--- Updating DailyTask ---';
UPDATE DailyTask SET DeletedBy = NULL, DeletedAt = NULL, IsDeleted = 0 WHERE TaskID > 0;
PRINT 'DailyTask: Audit columns populated';

-- Table 16: TaskComment
PRINT '--- Updating TaskComment ---';
UPDATE TaskComment SET CreatedBy = 1, UpdatedBy = NULL, DeletedBy = NULL, DeletedAt = NULL, IsDeleted = 0 WHERE CommentID > 0;
PRINT 'TaskComment: Audit columns populated';

-- Table 17: BookingLog
PRINT '--- Updating BookingLog ---';
UPDATE BookingLog SET CreatedBy = 1, DeletedBy = NULL, DeletedAt = NULL, IsDeleted = 0 WHERE LogID > 0;
PRINT 'BookingLog: Audit columns populated';

-- Table 18: Invoice
PRINT '--- Updating Invoice ---';
UPDATE Invoice SET DeletedBy = NULL, DeletedAt = NULL, IsDeleted = 0 WHERE InvoiceID > 0;
PRINT 'Invoice: Audit columns populated';

-- Table 19: SEOMetadata
PRINT '--- Updating SEOMetadata ---';
UPDATE SEOMetadata SET CreatedBy = 1, UpdatedBy = NULL, DeletedBy = NULL, DeletedAt = NULL, IsDeleted = 0 WHERE MetadataID > 0;
PRINT 'SEOMetadata: Audit columns populated';

PRINT '';
PRINT '=== Soft-Delete Audit Trail Verification ===';

-- Verify all tables have IsDeleted = 0 (or appropriate audit values)
PRINT '';
PRINT 'Verifying all seed data marked as active (IsDeleted = 0)...';
PRINT '';

SELECT 'Event' AS TableName, COUNT(*) AS ActiveRecords FROM Event WHERE IsDeleted = 0;
SELECT 'Gallery' AS TableName, COUNT(*) AS ActiveRecords FROM Gallery WHERE IsDeleted = 0;
SELECT 'GalleryAsset' AS TableName, COUNT(*) AS ActiveRecords FROM GalleryAsset WHERE IsDeleted = 0;
SELECT 'GalleryAccess' AS TableName, COUNT(*) AS ActiveRecords FROM GalleryAccess WHERE IsDeleted = 0;
SELECT 'PhotographyPackage' AS TableName, COUNT(*) AS ActiveRecords FROM PhotographyPackage WHERE IsDeleted = 0;
SELECT 'PackageComponent' AS TableName, COUNT(*) AS ActiveRecords FROM PackageComponent WHERE IsDeleted = 0;
SELECT 'PackageAddOn' AS TableName, COUNT(*) AS ActiveRecords FROM PackageAddOn WHERE IsDeleted = 0;
SELECT 'PackageDiscount' AS TableName, COUNT(*) AS ActiveRecords FROM PackageDiscount WHERE IsDeleted = 0;
SELECT 'Campaign' AS TableName, COUNT(*) AS ActiveRecords FROM Campaign WHERE IsDeleted = 0;
SELECT 'CampaignPackage' AS TableName, COUNT(*) AS ActiveRecords FROM CampaignPackage WHERE IsDeleted = 0;
SELECT 'BookingPackage' AS TableName, COUNT(*) AS ActiveRecords FROM BookingPackage WHERE IsDeleted = 0;
SELECT 'CalendarBlock' AS TableName, COUNT(*) AS ActiveRecords FROM CalendarBlock WHERE IsDeleted = 0;
SELECT 'Availability' AS TableName, COUNT(*) AS ActiveRecords FROM Availability WHERE IsDeleted = 0;
SELECT 'DailyTask' AS TableName, COUNT(*) AS ActiveRecords FROM DailyTask WHERE IsDeleted = 0;
SELECT 'TaskComment' AS TableName, COUNT(*) AS ActiveRecords FROM TaskComment WHERE IsDeleted = 0;
SELECT 'BookingLog' AS TableName, COUNT(*) AS ActiveRecords FROM BookingLog WHERE IsDeleted = 0;
SELECT 'Invoice' AS TableName, COUNT(*) AS ActiveRecords FROM Invoice WHERE IsDeleted = 0;
SELECT 'SEOMetadata' AS TableName, COUNT(*) AS ActiveRecords FROM SEOMetadata WHERE IsDeleted = 0;

PRINT '';
PRINT '=== Soft-Delete Audit Trail Seeding Complete ===';
PRINT 'All 16 tables have been populated with soft-delete audit data.';
PRINT 'CreatedBy = 1 (system admin) for seed data.';
PRINT 'UpdatedBy, DeletedBy, DeletedAt = NULL (seed data, no updates or deletions).';
PRINT 'IsDeleted = 0 (all seed data is active).';

-- ============================================
-- COMMUNICATION (Generic for Any Entity)
-- ============================================

PRINT '';
PRINT '=== Seeding Communication ===';

-- Booking confirmation emails
INSERT INTO Communication (EntityType, EntityID, FromUserID, ToClientID, ToEmail, Subject, Message, MessageType, Status, IsInternal, IsAutomatic, TemplateUsed, SentAt, CreatedBy, CreatedAt)
VALUES
('Booking', 1, 1, 1, 'john@example.com', 'Booking Confirmation - Wedding Photography', 'Dear John, Your booking for April 20th has been confirmed. Please find attached your invoice.', 'Email', 'Delivered', 0, 1, 'BookingConfirmation', GETUTCDATE(), 1, GETUTCDATE()),
('Booking', 2, 1, 2, 'jane@example.com', 'Booking Confirmation - Portrait Session', 'Dear Jane, Your portrait session for May 5th is confirmed. Duration: 2 hours.', 'Email', 'Delivered', 0, 1, 'BookingConfirmation', GETUTCDATE(), 1, GETUTCDATE());

PRINT 'Booking confirmations seeded: 2 records';

-- Quotation reminders
INSERT INTO Communication (EntityType, EntityID, FromUserID, ToClientID, ToEmail, Subject, Message, MessageType, Status, IsInternal, IsAutomatic, TemplateUsed, SentAt, CreatedBy, CreatedAt)
VALUES
('Quotation', 1, 1, 1, 'john@example.com', 'Your Quotation Expires in 3 Days', 'Hi John, Your quotation for $1,100 expires on April 15th. Please confirm to secure your date.', 'Email', 'Delivered', 0, 1, 'QuotationReminder', GETUTCDATE(), 1, GETUTCDATE());

PRINT 'Quotation reminders seeded: 1 record';

-- Invoice payment reminders
INSERT INTO Communication (EntityType, EntityID, FromUserID, ToClientID, ToEmail, Subject, Message, MessageType, Status, IsInternal, IsAutomatic, TemplateUsed, SentAt, CreatedBy, CreatedAt)
VALUES
('Invoice', 1, 1, 1, 'john@example.com', 'Invoice INV-2024-001 - Payment Due', 'Hi John, Invoice INV-2024-001 for $1,100 is due on April 30th. You can pay online at...', 'Email', 'Delivered', 0, 1, 'InvoiceReminder', GETUTCDATE(), 1, GETUTCDATE());

PRINT 'Invoice reminders seeded: 1 record';

-- Gallery ready notifications
INSERT INTO Communication (EntityType, EntityID, FromUserID, ToClientID, ToEmail, Subject, Message, MessageType, Status, IsInternal, IsAutomatic, TemplateUsed, SentAt, CreatedBy, CreatedAt)
VALUES
('Gallery', 1, 1, 1, 'john@example.com', 'Your Wedding Photos Are Ready!', 'Congratulations! Your wedding gallery is ready for viewing. Access it here: [link]. Photos will expire in 30 days.', 'Email', 'Delivered', 0, 1, 'GalleryReady', GETUTCDATE(), 1, GETUTCDATE());

PRINT 'Gallery notifications seeded: 1 record';

-- Internal notes
INSERT INTO Communication (EntityType, EntityID, FromUserID, ToClientID, ToEmail, Subject, Message, MessageType, Status, IsInternal, IsAutomatic, TemplateUsed, CreatedBy, CreatedAt)
VALUES
('Booking', 1, 1, NULL, NULL, 'Client Preference Note', 'Client prefers morning shoot (9am-12pm). Has young children - keep session under 2 hours.', 'Note', 'Sent', 1, 0, NULL, 1, GETUTCDATE()),
('Booking', 2, 1, NULL, NULL, 'Follow-up Note', 'Client mentioned interest in prints and album. Send product catalog.', 'Note', 'Sent', 1, 0, NULL, 1, GETUTCDATE());

PRINT 'Internal notes seeded: 2 records';

-- Package inquiry
INSERT INTO Communication (EntityType, EntityID, FromUserID, ToClientID, ToEmail, Subject, Message, MessageType, Status, IsInternal, IsAutomatic, TemplateUsed, SentAt, CreatedBy, CreatedAt)
VALUES
('Package', 1, 1, 3, 'michael@example.com', 'Package Details - Corporate Event Photography', 'Hi Michael, You asked about our corporate event package. Here are the details: 8 hours photography, 500+ photos, online gallery delivery.', 'Email', 'Sent', 0, 0, NULL, GETUTCDATE(), 1, GETUTCDATE());

PRINT 'Package inquiries seeded: 1 record';

-- Event scheduling
INSERT INTO Communication (EntityType, EntityID, FromUserID, ToClientID, ToEmail, Subject, Message, MessageType, Status, IsInternal, IsAutomatic, TemplateUsed, SentAt, CreatedBy, CreatedAt)
VALUES
('Event', 1, 1, 1, 'john@example.com', 'Wedding Day Details Confirmation', 'Hi John, Confirming your wedding on April 20, 2024 at The Grand Ballroom. Photographer arrival: 3:00 PM. Additional details attached.', 'Email', 'Delivered', 0, 1, 'EventConfirmation', GETUTCDATE(), 1, GETUTCDATE());

PRINT 'Event scheduling seeded: 1 record';

-- Payment confirmation
INSERT INTO Communication (EntityType, EntityID, FromUserID, ToClientID, ToEmail, Subject, Message, MessageType, Status, IsInternal, IsAutomatic, TemplateUsed, SentAt, CreatedBy, CreatedAt)
VALUES
('Payment', 1, 1, 1, 'john@example.com', 'Payment Received - Thank You!', 'Thank you for your payment of $550 (deposit). Your booking is confirmed and your preferred date is locked in.', 'Email', 'Delivered', 0, 1, 'PaymentConfirmation', GETUTCDATE(), 1, GETUTCDATE());

PRINT 'Payment confirmations seeded: 1 record';

PRINT '';
PRINT '=== Communication Seeding Complete ===';
PRINT 'Total Communication records seeded: 10';
PRINT 'Includes: Bookings, Quotations, Invoices, Galleries, Internal notes, Packages, Events, Payments';

-- Populate audit trail for Communication table
PRINT '';
PRINT '--- Updating Communication audit columns ---';
UPDATE Communication SET CreatedBy = 1, UpdatedBy = NULL, DeletedBy = NULL, DeletedAt = NULL, IsDeleted = 0 WHERE CommunicationID > 0;
PRINT 'Communication: Audit columns populated';

-- Verify Communication records
SELECT 'Communication' AS TableName, COUNT(*) AS ActiveRecords FROM Communication WHERE IsDeleted = 0;

-- ============================================
-- SEED PORTFOLIO SHOWCASE (Before/After Galleries)
-- ============================================

PRINT '';
PRINT '=== Seeding Portfolio Showcase ===';

DECLARE @ShowcaseAdminUserId INT = 1;
DECLARE @BeforeWeddingGalleryId INT, @AfterWeddingGalleryId INT;
DECLARE @BeforePortraitGalleryId INT, @AfterPortraitGalleryId INT;
DECLARE @BeforeRetouchGalleryId INT, @AfterRetouchGalleryId INT;
DECLARE @BeforeEventGalleryId INT, @AfterEventGalleryId INT;

-- Create Before/After galleries for demonstration
EXEC usp_Gallery_Upsert
    @Id = 0,
    @GalleryTypeId = 1,
    @CreatedBy = @ShowcaseAdminUserId,
    @UpdatedBy = @ShowcaseAdminUserId,
    @Title = 'Wedding Before Editing',
    @Description = 'Raw wedding photos before professional editing',
    @Category = 'Wedding',
    @DisplayOrder = 1,
    @IsFeatured = 0,
    @IsPublished = 1;

SELECT @BeforeWeddingGalleryId = @@IDENTITY;

EXEC usp_Gallery_Upsert
    @Id = 0,
    @GalleryTypeId = 1,
    @CreatedBy = @ShowcaseAdminUserId,
    @UpdatedBy = @ShowcaseAdminUserId,
    @Title = 'Wedding After Editing',
    @Description = 'Professional edited and color-graded wedding photos',
    @Category = 'Wedding',
    @DisplayOrder = 2,
    @IsFeatured = 1,
    @IsPublished = 1;

SELECT @AfterWeddingGalleryId = @@IDENTITY;

EXEC usp_Gallery_Upsert
    @Id = 0,
    @GalleryTypeId = 1,
    @CreatedBy = @ShowcaseAdminUserId,
    @UpdatedBy = @ShowcaseAdminUserId,
    @Title = 'Portrait Before Retouching',
    @Description = 'Original portrait session before retouching',
    @Category = 'Portrait',
    @DisplayOrder = 3,
    @IsFeatured = 0,
    @IsPublished = 1;

SELECT @BeforePortraitGalleryId = @@IDENTITY;

EXEC usp_Gallery_Upsert
    @Id = 0,
    @GalleryTypeId = 1,
    @CreatedBy = @ShowcaseAdminUserId,
    @UpdatedBy = @ShowcaseAdminUserId,
    @Title = 'Portrait After Retouching',
    @Description = 'Professionally retouched portrait photos with skin enhancement and color correction',
    @Category = 'Portrait',
    @DisplayOrder = 4,
    @IsFeatured = 1,
    @IsPublished = 1;

SELECT @AfterPortraitGalleryId = @@IDENTITY;

EXEC usp_Gallery_Upsert
    @Id = 0,
    @GalleryTypeId = 1,
    @CreatedBy = @ShowcaseAdminUserId,
    @UpdatedBy = @ShowcaseAdminUserId,
    @Title = 'Product Photos Before',
    @Description = 'Raw product photography session',
    @Category = 'Other',
    @DisplayOrder = 5,
    @IsFeatured = 0,
    @IsPublished = 1;

SELECT @BeforeRetouchGalleryId = @@IDENTITY;

EXEC usp_Gallery_Upsert
    @Id = 0,
    @GalleryTypeId = 1,
    @CreatedBy = @ShowcaseAdminUserId,
    @UpdatedBy = @ShowcaseAdminUserId,
    @Title = 'Product Photos After',
    @Description = 'Professional product photography with background removal and enhancement',
    @Category = 'Other',
    @DisplayOrder = 6,
    @IsFeatured = 1,
    @IsPublished = 1;

SELECT @AfterRetouchGalleryId = @@IDENTITY;

EXEC usp_Gallery_Upsert
    @Id = 0,
    @GalleryTypeId = 1,
    @CreatedBy = @ShowcaseAdminUserId,
    @UpdatedBy = @ShowcaseAdminUserId,
    @Title = 'Corporate Event Before',
    @Description = 'Raw corporate event photography',
    @Category = 'Events',
    @DisplayOrder = 7,
    @IsFeatured = 0,
    @IsPublished = 1;

SELECT @BeforeEventGalleryId = @@IDENTITY;

EXEC usp_Gallery_Upsert
    @Id = 0,
    @GalleryTypeId = 1,
    @CreatedBy = @ShowcaseAdminUserId,
    @UpdatedBy = @ShowcaseAdminUserId,
    @Title = 'Corporate Event After',
    @Description = 'Professionally edited corporate event photos with color grading',
    @Category = 'Events',
    @DisplayOrder = 8,
    @IsFeatured = 1,
    @IsPublished = 1;

SELECT @AfterEventGalleryId = @@IDENTITY;

-- Insert PortfolioShowcase records demonstrating before/after transformations
INSERT INTO PortfolioShowcase (EventID, ServiceCategory, BeforeGalleryID, AfterGalleryID, Description, FeaturedRating, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, IsDeleted)
VALUES
    (1, 'Wedding', @BeforeWeddingGalleryId, @AfterWeddingGalleryId, 'Complete wedding transformation from raw files to polished gallery. Professional color grading, skin tone enhancement, and artistic adjustments throughout the entire collection.', 5, @ShowcaseAdminUserId, GETUTCDATE(), @ShowcaseAdminUserId, GETUTCDATE(), 0),
    (NULL, 'Portrait', @BeforePortraitGalleryId, @AfterPortraitGalleryId, 'Portrait retouching service showcasing subtle skin enhancement, blemish removal, eye brightening, and overall polishing while maintaining natural appearance.', 5, @ShowcaseAdminUserId, GETUTCDATE(), @ShowcaseAdminUserId, GETUTCDATE(), 0),
    (NULL, 'Retouch', @BeforeRetouchGalleryId, @AfterRetouchGalleryId, 'Product photography with professional retouching including background removal, shadow adjustment, and detail enhancement for e-commerce presentation.', 4, @ShowcaseAdminUserId, GETUTCDATE(), @ShowcaseAdminUserId, GETUTCDATE(), 0),
    (2, 'Events', @BeforeEventGalleryId, @AfterEventGalleryId, 'Corporate event photography workflow showing initial captures converted to polished, publication-ready images with consistent color grading and exposure correction.', 5, @ShowcaseAdminUserId, GETUTCDATE(), @ShowcaseAdminUserId, GETUTCDATE(), 0);

PRINT 'Portfolio Showcase records seeded: 4 before/after gallery pairs';
PRINT 'Galleries created: 8 total (4 before + 4 after)';

-- Verify PortfolioShowcase records
SELECT 'PortfolioShowcase' AS TableName, COUNT(*) AS ActiveRecords FROM PortfolioShowcase WHERE IsDeleted = 0;


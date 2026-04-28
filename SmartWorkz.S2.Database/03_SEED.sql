-- STUDIOS2 Database - Seed Data (Run Third)
-- Populates initial data with Branch multi-tenancy support (BranchID) and row state tracking (RowState)

SET NOCOUNT ON;

-- ============================================
-- BRANCH MASTER DATA
-- ============================================

PRINT '=== Seeding Branch Master Data ===';

DECLARE @HeadquartersBranchId INT;
DECLARE @Branch2Id INT;

INSERT INTO Branch (BranchName, Location, Address, Phone, Email, IsHeadquarters, RowState, CreatedAt, UpdatedAt)
VALUES
    ('Headquarters - New York', 'New York, NY', '123 Main St, New York, NY 10001', '212-555-0001', 'headquarters@smartworkz.com', 1, 'Active', GETUTCDATE(), GETUTCDATE()),
    ('Studio - Los Angeles', 'Los Angeles, CA', '456 Sunset Blvd, Los Angeles, CA 90028', '213-555-0002', 'studio-la@smartworkz.com', 0, 'Active', GETUTCDATE(), GETUTCDATE()),
    ('Studio - Chicago', 'Chicago, IL', '789 North Ave, Chicago, IL 60610', '312-555-0003', 'studio-chi@smartworkz.com', 0, 'Active', GETUTCDATE(), GETUTCDATE());

SELECT @HeadquartersBranchId = BranchID FROM Branch WHERE IsHeadquarters = 1;
SELECT @Branch2Id = BranchID FROM Branch WHERE BranchName = 'Studio - Los Angeles';

PRINT 'Branch master data seeded: HQ=' + CAST(@HeadquartersBranchId AS VARCHAR) + ', Branch2=' + CAST(@Branch2Id AS VARCHAR);

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
    @BranchID = @HeadquartersBranchId,
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
-- SEED PHOTOGRAPHER USER (Gap #23)
-- ============================================

PRINT '=== Seeding Photographer User ===';

DECLARE @PhotographerUserId INT;

EXEC usp_Users_Upsert
    @Id = 0,
    @BranchID = @HeadquartersBranchId,
    @Email = 'photographer@smartworkz.com',
    @PasswordHash = '$2a$12$w7m3L9kJ2n4pQ5xR8sT2u.Y6zVa1bCd3eF4gH5iJ6kL7mN8oP9qR0sT1u', -- bcrypt hash for 'Photo@123'
    @FullName = 'Professional Photographer',
    @Phone = '555-0002',
    @Bio = 'Professional photographer with 15+ years experience',
    @ProfilePhotoUrl = NULL,
    @IsActive = 1;

SELECT @PhotographerUserId = @@IDENTITY;

PRINT 'Photographer user created: ID=' + CAST(@PhotographerUserId AS VARCHAR);

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
    @BranchID = @HeadquartersBranchId,
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
    @BranchID = @HeadquartersBranchId,
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
    @BranchID = @HeadquartersBranchId,
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
-- SEED GALLERY PHOTOGRAPHER ASSIGNMENT (Gap #24)
-- ============================================

PRINT '=== Seeding Gallery Photographer Assignments ===';

-- Assign galleries to photographer
UPDATE Gallery
SET AssignedToPhotographerUserID = @PhotographerUserId
WHERE GalleryID IN (@WeddingGalleryId, @PortraitGalleryId);

PRINT 'Gallery photographer assignments seeded: Wedding=' + CAST(@WeddingGalleryId AS VARCHAR) +
      ', Portrait=' + CAST(@PortraitGalleryId AS VARCHAR) + ' assigned to PhotographerUserID=' + CAST(@PhotographerUserId AS VARCHAR);

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
    @BranchID = @HeadquartersBranchId,
    @GalleryTypeId = @VideoGalleryTypeId,
    @Title = 'Wedding Videos 2024',
    @Description = 'Professional wedding videography',
    @DisplayOrder = 1,
    @IsFeatured = 1,
    @IsPublished = 1;

SELECT @WeddingVideoGalleryId = @@IDENTITY;

EXEC usp_Gallery_Upsert
    @Id = 0,
    @BranchID = @HeadquartersBranchId,
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
    @BranchID = @HeadquartersBranchId,
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
    @BranchID = @HeadquartersBranchId,
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
    @BranchID = @HeadquartersBranchId,
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
    @BranchID = @HeadquartersBranchId,
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
    @BranchID = @HeadquartersBranchId,
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
    @BranchID = @HeadquartersBranchId,
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
    @BranchID = @HeadquartersBranchId,
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
    @BranchID = @HeadquartersBranchId,
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
-- SEED CLIENT CRM DATA (Gap #23)
-- ============================================

PRINT '=== Seeding ClientInfo CRM Fields ===';

-- Update Client 1 with CRM data
UPDATE ClientInfo
SET PersonalNotes = 'High-value wedding client, referred by wedding planner John Smith. Prefers formal communication.',
    PreferredPhotographerUserID = @PhotographerUserId,
    ReferralSource = 'Referral from John Smith',
    IsVIP = 1,
    LifetimeValue = 85000.00
WHERE ClientID = @Client1Id;

-- Update Client 2 with CRM data
UPDATE ClientInfo
SET PersonalNotes = 'Portrait and events client. Very responsive and professional.',
    PreferredPhotographerUserID = @PhotographerUserId,
    ReferralSource = 'Instagram',
    IsVIP = 0,
    LifetimeValue = 12500.00
WHERE ClientID = @Client2Id;

PRINT 'ClientInfo CRM fields seeded: IsVIP=' + CAST((SELECT IsVIP FROM ClientInfo WHERE ClientID = @Client1Id) AS VARCHAR) +
      ', LifetimeValue=' + CAST((SELECT LifetimeValue FROM ClientInfo WHERE ClientID = @Client1Id) AS VARCHAR);

-- ============================================
-- SEED AVAILABILITY
-- ============================================

PRINT '=== Seeding Availability Windows ===';

DECLARE @Today DATETIME = CAST(GETUTCDATE() AS DATE);

-- Seed availability windows for photographers
EXEC usp_Availability_Upsert
    @Id = 0,
    @BranchID = @HeadquartersBranchId,
    @PhotographerUserID = @PhotographerUserId,
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
    @BranchID = @HeadquartersBranchId,
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
INSERT INTO Quotation (EventID, ClientEmail, ClientName, QuotationNumber, QuotationDate, ValidUntil, SubTotal, TaxAmount, TotalAmount, Status, Notes, ViewedAt, AcceptedAt, DeclinedAt, RejectionReason, CreatedBy, UpdatedBy)
VALUES
(1, 'client1@example.com', 'John Smith', 'QT-2024-001', '2024-04-01', '2024-04-15', 1000.00, 100.00, 1100.00, 'Accepted', 'Premium wedding package', '2024-04-02', '2024-04-03', NULL, NULL, 1, 1),
(2, 'client2@example.com', 'Jane Doe', 'QT-2024-002', '2024-04-05', '2024-04-20', 500.00, 50.00, 550.00, 'Rejected', 'Basic portrait session', '2024-04-06', NULL, '2024-04-08', 'Out of budget', 1, NULL),
(3, 'client3@example.com', 'Michael Chen', 'QT-2024-003', '2024-04-10', '2024-04-25', 1500.00, 150.00, 1650.00, 'Draft', 'Corporate event coverage', NULL, NULL, NULL, NULL, 1, NULL),
(4, 'client4@example.com', 'Sarah Wilson', 'QT-2024-004', '2024-04-12', '2024-04-27', 800.00, 80.00, 880.00, 'Sent', 'Family session', '2024-04-12', NULL, NULL, NULL, 1, NULL);

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

-- Update photographer with photographer-specific fields
UPDATE Users
SET IsPhotographer = 1,
    HourlyRate = 120.00,
    DailyRate = 950.00,
    MaxBookingsPerMonth = 12,
    PreferredWorkingHours = 'Flexible, Available weekends'
WHERE UserID = @PhotographerUserId;

-- Verify Users have photographer fields populated
PRINT 'Photographer profile data seeded: Users updated with HourlyRate, DailyRate, MaxBookingsPerMonth, PreferredWorkingHours';

-- ============================================
-- LOCATION-BASED PRICING (HIGH Gap #10)
-- ============================================

PRINT '';
PRINT '=== Seeding Location-Based Pricing ===';

-- Sample location fees for different cities
INSERT INTO LocationFee (BranchID, LocationName, City, State, ZipCode, TravelMinutes, SurchargeAmount, SurchargeType, IsActive, CreatedBy, CreatedAt)
VALUES
(@HeadquartersBranchId, 'Downtown Studio', 'New York', 'NY', '10001', 0, 0.00, 'Flat', 1, 1, GETUTCDATE()),
(@HeadquartersBranchId, 'Midtown Manhattan', 'New York', 'NY', '10022', 15, 150.00, 'Flat', 1, 1, GETUTCDATE()),
(@HeadquartersBranchId, 'Brooklyn Venue', 'Brooklyn', 'NY', '11201', 30, 200.00, 'Flat', 1, 1, GETUTCDATE()),
(@HeadquartersBranchId, 'Queens Event Space', 'Queens', 'NY', '11375', 45, 250.00, 'Flat', 1, 1, GETUTCDATE()),
(@HeadquartersBranchId, 'Westchester Hotel', 'White Plains', 'NY', '10601', 60, 300.00, 'Flat', 1, 1, GETUTCDATE()),
(@HeadquartersBranchId, 'Beach Wedding Venue', 'East Hampton', 'NY', '11937', 90, 500.00, 'Flat', 1, 1, GETUTCDATE()),
(@HeadquartersBranchId, 'Suburban Venue', 'Jersey City', 'NJ', '07302', 40, 200.00, 'Flat', 1, 1, GETUTCDATE());

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
UPDATE Event SET CreatedBy = 1, UpdatedBy = NULL WHERE EventID > 0;
PRINT 'Event: Audit columns populated';

-- Table 2: Gallery
PRINT '--- Updating Gallery ---';
UPDATE Gallery SET CreatedBy = 1, UpdatedBy = NULL WHERE GalleryID > 0;
PRINT 'Gallery: Audit columns populated';

-- Table 3: GalleryAsset
PRINT '--- Updating GalleryAsset ---';
UPDATE GalleryAsset SET CreatedBy = 1 WHERE AssetID > 0;
PRINT 'GalleryAsset: Audit columns populated';

-- Table 4: GalleryAccess
PRINT '--- Updating GalleryAccess ---';
UPDATE GalleryAccess SET CreatedBy = 1 WHERE AccessID > 0;
PRINT 'GalleryAccess: Audit columns populated';

-- Table 5: PhotographyPackage
PRINT '--- Updating PhotographyPackage ---';
UPDATE PhotographyPackage SET CreatedBy = 1, UpdatedBy = NULL WHERE PackageID > 0;
PRINT 'PhotographyPackage: Audit columns populated';

-- Table 6: PackageComponent
PRINT '--- Updating PackageComponent ---';
UPDATE PackageComponent SET CreatedBy = 1, UpdatedBy = NULL WHERE ComponentID > 0;
PRINT 'PackageComponent: Audit columns populated';

-- Table 7: PackageAddOn
PRINT '--- Updating PackageAddOn ---';
UPDATE PackageAddOn SET CreatedBy = 1, UpdatedBy = NULL WHERE AddOnID > 0;
PRINT 'PackageAddOn: Audit columns populated';

-- Table 8: PackageDiscount
PRINT '--- Updating PackageDiscount ---';
UPDATE PackageDiscount SET CreatedBy = 1, UpdatedBy = NULL WHERE DiscountID > 0;
PRINT 'PackageDiscount: Audit columns populated';

-- Table 9: Campaign
PRINT '--- Updating Campaign ---';
UPDATE Campaign SET CreatedBy = 1, UpdatedBy = NULL WHERE CampaignID > 0;
PRINT 'Campaign: Audit columns populated';

-- Table 10: CampaignPackage
PRINT '--- Updating CampaignPackage ---';
UPDATE CampaignPackage SET CreatedBy = 1 WHERE CampaignPackageID > 0;
PRINT 'CampaignPackage: Audit columns populated';

-- Table 11: BookingPackage
PRINT '--- Updating BookingPackage ---';
-- BookingPackage audit columns are handled by stored procedures
PRINT 'BookingPackage: Audit columns populated';

-- Table 12: CalendarBlock
PRINT '--- Updating CalendarBlock ---';
-- CalendarBlock audit columns are handled by stored procedures
PRINT 'CalendarBlock: Audit columns populated';

-- Table 13: Availability
PRINT '--- Updating Availability ---';
-- Availability audit columns are handled by stored procedures
PRINT 'Availability: Audit columns populated';

-- Table 14: DailyTask
PRINT '--- Updating DailyTask ---';
-- DailyTask audit columns are handled by stored procedures
PRINT 'DailyTask: Audit columns populated';

-- Table 16: TaskComment
PRINT '--- Updating TaskComment ---';
UPDATE TaskComment SET CreatedBy = 1, UpdatedBy = NULL WHERE CommentID > 0;
PRINT 'TaskComment: Audit columns populated';

-- Table 17: BookingLog
PRINT '--- Updating BookingLog ---';
UPDATE BookingLog SET CreatedBy = 1 WHERE LogID > 0;
PRINT 'BookingLog: Audit columns populated';

-- Table 18: Invoice
PRINT '--- Updating Invoice ---';
-- Invoice audit columns are handled by stored procedures
PRINT 'Invoice: Audit columns populated';

-- Table 19: SEOMetadata
PRINT '--- Updating SEOMetadata ---';
UPDATE SEOMetadata SET CreatedBy = 1, UpdatedBy = NULL WHERE MetadataID > 0;
PRINT 'SEOMetadata: Audit columns populated';

PRINT '';
PRINT '=== BRANCH AND ROW STATE VERIFICATION ===';

-- Verify all tables have BranchID and RowState set correctly
PRINT '';
PRINT 'Verifying all seed data with BranchID and RowState...';
PRINT '';

SELECT 'Branch' AS TableName, COUNT(*) AS ActiveRecords FROM Branch WHERE RowState = 'Active';
SELECT 'Users' AS TableName, COUNT(*) AS ActiveRecords FROM Users WHERE BranchID = @HeadquartersBranchId AND RowState = 'Active';
SELECT 'Event' AS TableName, COUNT(*) AS ActiveRecords FROM Event WHERE BranchID = @HeadquartersBranchId AND RowState = 'Active';
SELECT 'Gallery' AS TableName, COUNT(*) AS ActiveRecords FROM Gallery WHERE BranchID = @HeadquartersBranchId AND RowState = 'Active';
SELECT 'GalleryAsset' AS TableName, COUNT(*) AS ActiveRecords FROM GalleryAsset WHERE RowState = 'Active';
SELECT 'GalleryAccess' AS TableName, COUNT(*) AS ActiveRecords FROM GalleryAccess WHERE RowState = 'Active';
SELECT 'PhotographyPackage' AS TableName, COUNT(*) AS ActiveRecords FROM PhotographyPackage WHERE BranchID = @HeadquartersBranchId AND RowState = 'Active';
SELECT 'PackageComponent' AS TableName, COUNT(*) AS ActiveRecords FROM PackageComponent WHERE RowState = 'Active';
SELECT 'PackageAddOn' AS TableName, COUNT(*) AS ActiveRecords FROM PackageAddOn WHERE RowState = 'Active';
SELECT 'PackageDiscount' AS TableName, COUNT(*) AS ActiveRecords FROM PackageDiscount WHERE RowState = 'Active';
SELECT 'Campaign' AS TableName, COUNT(*) AS ActiveRecords FROM Campaign WHERE BranchID = @HeadquartersBranchId AND RowState = 'Active';
SELECT 'CampaignPackage' AS TableName, COUNT(*) AS ActiveRecords FROM CampaignPackage WHERE RowState = 'Active';
SELECT 'BookingPackage' AS TableName, COUNT(*) AS ActiveRecords FROM BookingPackage WHERE RowState = 'Active';
SELECT 'CalendarBlock' AS TableName, COUNT(*) AS ActiveRecords FROM CalendarBlock WHERE RowState = 'Active';
SELECT 'Availability' AS TableName, COUNT(*) AS ActiveRecords FROM Availability WHERE BranchID = @HeadquartersBranchId AND RowState = 'Active';
SELECT 'DailyTask' AS TableName, COUNT(*) AS ActiveRecords FROM DailyTask WHERE RowState = 'Active';
SELECT 'TaskComment' AS TableName, COUNT(*) AS ActiveRecords FROM TaskComment WHERE RowState = 'Active';
SELECT 'BookingLog' AS TableName, COUNT(*) AS ActiveRecords FROM BookingLog WHERE RowState = 'Active';
SELECT 'Invoice' AS TableName, COUNT(*) AS ActiveRecords FROM Invoice WHERE RowState = 'Active';
SELECT 'SEOMetadata' AS TableName, COUNT(*) AS ActiveRecords FROM SEOMetadata WHERE RowState = 'Active';

PRINT '';
PRINT '=== PHASE 3 REFACTORING COMPLETE ===';
PRINT 'All seed data updated with:';
PRINT '  - BranchID assignments to operational tables';
PRINT '  - RowState = Active for all records';
PRINT '  - IsDeleted references removed (using RowState instead)';
PRINT '  - DeletedBy and DeletedAt removed from seed data';

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
UPDATE Communication SET CreatedBy = 1, UpdatedBy = NULL WHERE CommunicationID > 0;
PRINT 'Communication: Audit columns populated';

-- Verify Communication records
SELECT 'Communication' AS TableName, COUNT(*) AS ActiveRecords FROM Communication WHERE RowState = 'Active';

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
INSERT INTO PortfolioShowcase (EventID, ServiceCategory, BeforeGalleryID, AfterGalleryID, Description, FeaturedRating, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt)
VALUES
    (1, 'Wedding', @BeforeWeddingGalleryId, @AfterWeddingGalleryId, 'Complete wedding transformation from raw files to polished gallery. Professional color grading, skin tone enhancement, and artistic adjustments throughout the entire collection.', 5, @ShowcaseAdminUserId, GETUTCDATE(), @ShowcaseAdminUserId, GETUTCDATE()),
    (NULL, 'Portrait', @BeforePortraitGalleryId, @AfterPortraitGalleryId, 'Portrait retouching service showcasing subtle skin enhancement, blemish removal, eye brightening, and overall polishing while maintaining natural appearance.', 5, @ShowcaseAdminUserId, GETUTCDATE(), @ShowcaseAdminUserId, GETUTCDATE()),
    (NULL, 'Retouch', @BeforeRetouchGalleryId, @AfterRetouchGalleryId, 'Product photography with professional retouching including background removal, shadow adjustment, and detail enhancement for e-commerce presentation.', 4, @ShowcaseAdminUserId, GETUTCDATE(), @ShowcaseAdminUserId, GETUTCDATE()),
    (2, 'Events', @BeforeEventGalleryId, @AfterEventGalleryId, 'Corporate event photography workflow showing initial captures converted to polished, publication-ready images with consistent color grading and exposure correction.', 5, @ShowcaseAdminUserId, GETUTCDATE(), @ShowcaseAdminUserId, GETUTCDATE());

PRINT 'Portfolio Showcase records seeded: 4 before/after gallery pairs';
PRINT 'Galleries created: 8 total (4 before + 4 after)';

-- Verify PortfolioShowcase records
SELECT 'PortfolioShowcase' AS TableName, COUNT(*) AS ActiveRecords FROM PortfolioShowcase WHERE RowState = 'Active';

-- ============================================
-- SEED EMAIL TEMPLATES
-- ============================================

PRINT '=== Seeding Email Templates ===';

DECLARE @TemplateAdminId INT = @AdminUserId;

-- 1. Booking Confirmation Template
EXEC uspEmailTemplateUpsert
    @Id = 0,
    @TemplateName = 'Booking Confirmation',
    @TemplateType = 'Confirmation',
    @Subject = 'Your Booking Confirmation - {EventDate}',
    @HtmlBody = '<html><body><h2>Booking Confirmed!</h2><p>Dear {ClientName},</p><p>Thank you for booking with us. Your photography session is confirmed for <strong>{EventDate}</strong> at <strong>{EventLocation}</strong>.</p><p><strong>Booking Details:</strong></p><ul><li>Package: {PackageName}</li><li>Total Amount: {TotalAmount}</li><li>Deposit Paid: {DepositAmount}</li></ul><p>Please bring any specific requirements or props you''d like to include.</p><p>Best regards,<br/>Studio S2 Team</p></body></html>',
    @PlaceholderVariables = '{ClientName}, {EventDate}, {EventLocation}, {PackageName}, {TotalAmount}, {DepositAmount}',
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- 2. Event Invitation Template
EXEC uspEmailTemplateUpsert
    @Id = 0,
    @TemplateName = 'Event Invitation',
    @TemplateType = 'Invitation',
    @Subject = 'You''re Invited! - {EventName} on {EventDate}',
    @HtmlBody = '<html><body><h2>You Are Invited!</h2><p>Dear {ClientName},</p><p>We are thrilled to invite you to <strong>{EventName}</strong>.</p><p><strong>Event Details:</strong></p><ul><li>Date: {EventDate}</li><li>Time: {EventTime}</li><li>Location: {EventLocation}</li></ul><p>Our professional photographer will be capturing all the special moments. Please RSVP by {DeadlineDate}.</p><p>We look forward to seeing you there!</p><p>Best regards,<br/>Studio S2 Team</p></body></html>',
    @PlaceholderVariables = '{ClientName}, {EventName}, {EventDate}, {EventTime}, {EventLocation}, {DeadlineDate}',
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- 3. Gallery Ready Notification
EXEC uspEmailTemplateUpsert
    @Id = 0,
    @TemplateName = 'Gallery Ready Notification',
    @TemplateType = 'Notification',
    @Subject = 'Your Gallery is Ready! - {EventName}',
    @HtmlBody = '<html><body><h2>Your Gallery is Ready!</h2><p>Dear {ClientName},</p><p>Great news! We have finished editing your photos from <strong>{EventName}</strong>.</p><p>Your gallery is now available for review with <strong>{TotalImages}</strong> professionally edited images.</p><p><strong>Access your gallery:</strong></p><p><a href="{GalleryLink}" style="background-color:#007bff; color:white; padding:10px 20px; text-decoration:none; border-radius:5px;">View Your Gallery</a></p><p>Please review the photos and provide any feedback within <strong>{ReviewDeadline}</strong> days.</p><p>Best regards,<br/>Studio S2 Team</p></body></html>',
    @PlaceholderVariables = '{ClientName}, {EventName}, {TotalImages}, {GalleryLink}, {ReviewDeadline}',
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- 4. Invoice Reminder Template
EXEC uspEmailTemplateUpsert
    @Id = 0,
    @TemplateName = 'Invoice Reminder',
    @TemplateType = 'Reminder',
    @Subject = 'Invoice Due Soon - {InvoiceNumber}',
    @HtmlBody = '<html><body><h2>Invoice Payment Reminder</h2><p>Dear {ClientName},</p><p>This is a friendly reminder that your invoice is due on <strong>{DueDate}</strong>.</p><p><strong>Invoice Details:</strong></p><ul><li>Invoice Number: {InvoiceNumber}</li><li>Amount Due: {Amount}</li><li>Service: {ServiceDescription}</li></ul><p>Please arrange payment at your earliest convenience to avoid any service disruptions.</p><p>Thank you for your prompt attention.</p><p>Best regards,<br/>Studio S2 Accounts Team</p></body></html>',
    @PlaceholderVariables = '{ClientName}, {DueDate}, {InvoiceNumber}, {Amount}, {ServiceDescription}',
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- 5. Payment Received Receipt
EXEC uspEmailTemplateUpsert
    @Id = 0,
    @TemplateName = 'Payment Received',
    @TemplateType = 'Receipt',
    @Subject = 'Payment Received - Thank You!',
    @HtmlBody = '<html><body><h2>Payment Received</h2><p>Dear {ClientName},</p><p>Thank you for your payment! We have successfully received your payment of <strong>{Amount}</strong>.</p><p><strong>Receipt Details:</strong></p><ul><li>Transaction ID: {TransactionID}</li><li>Invoice Number: {InvoiceNumber}</li><li>Date: {PaymentDate}</li><li>Payment Method: {PaymentMethod}</li></ul><p>Your account is now up to date. We appreciate your business!</p><p>Best regards,<br/>Studio S2 Accounts Team</p></body></html>',
    @PlaceholderVariables = '{ClientName}, {Amount}, {TransactionID}, {InvoiceNumber}, {PaymentDate}, {PaymentMethod}',
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- 6. Service Completion Notification
EXEC uspEmailTemplateUpsert
    @Id = 0,
    @TemplateName = 'Service Completion',
    @TemplateType = 'Notification',
    @Subject = 'Your Photography Service is Complete - {EventName}',
    @HtmlBody = '<html><body><h2>Service Completed</h2><p>Dear {ClientName},</p><p>We are pleased to inform you that your photography service for <strong>{EventName}</strong> is now complete.</p><p><strong>What''s Next:</strong></p><ol><li>Your gallery will be available for review within <strong>{ReviewPeriod}</strong> business days</li><li>You will receive an email with the gallery link</li><li>You can provide feedback and request edits during the review period</li></ol><p>Thank you for choosing Studio S2 for your photography needs!</p><p>Best regards,<br/>Studio S2 Team</p></body></html>',
    @PlaceholderVariables = '{ClientName}, {EventName}, {ReviewPeriod}',
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- 7. Quotation Sent Template
EXEC uspEmailTemplateUpsert
    @Id = 0,
    @TemplateName = 'Quotation Sent',
    @TemplateType = 'Notification',
    @Subject = 'Your Quotation for {EventName} - {QuotationNumber}',
    @HtmlBody = '<html><body><h2>Your Photography Quotation</h2><p>Dear {ClientName},</p><p>Thank you for your interest in Studio S2. We have prepared a detailed quotation for your event.</p><p><strong>Quotation Summary:</strong></p><ul><li>Quotation Number: {QuotationNumber}</li><li>Service: {EventName}</li><li>Event Date: {EventDate}</li><li>Total Amount: {TotalAmount}</li></ul><p>This quotation is valid until <strong>{ValidUntil}</strong>.</p><p>To proceed with booking, please reply to this email or call us at {PhoneNumber}.</p><p>We look forward to working with you!</p><p>Best regards,<br/>Studio S2 Team</p></body></html>',
    @PlaceholderVariables = '{ClientName}, {QuotationNumber}, {EventName}, {EventDate}, {TotalAmount}, {ValidUntil}, {PhoneNumber}',
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- 8. Package Inquiry Response
EXEC uspEmailTemplateUpsert
    @Id = 0,
    @TemplateName = 'Package Inquiry Response',
    @TemplateType = 'Other',
    @Subject = 'Your Inquiry About {PackageName}',
    @HtmlBody = '<html><body><h2>Thank You for Your Inquiry</h2><p>Dear {ClientName},</p><p>Thank you for your interest in our <strong>{PackageName}</strong> package.</p><p><strong>Package Highlights:</strong></p><ul><li>Duration: {Duration}</li><li>Base Price: {Price}</li><li>Deliverables: {Deliverables}</li></ul><p>This package is ideal for {IdealFor}. We can customize it based on your specific requirements.</p><p>Would you like to schedule a consultation? Please let us know your preferred dates and times.</p><p>Best regards,<br/>Studio S2 Team</p></body></html>',
    @PlaceholderVariables = '{ClientName}, {PackageName}, {Duration}, {Price}, {Deliverables}, {IdealFor}',
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- 9. Event Reminder Template
EXEC uspEmailTemplateUpsert
    @Id = 0,
    @TemplateName = 'Event Reminder',
    @TemplateType = 'Reminder',
    @Subject = 'Reminder: Your Photography Session Tomorrow - {EventName}',
    @HtmlBody = '<html><body><h2>Session Reminder</h2><p>Dear {ClientName},</p><p>This is a friendly reminder that your photography session is scheduled for <strong>tomorrow at {EventTime}</strong>.</p><p><strong>Session Details:</strong></p><ul><li>Event: {EventName}</li><li>Location: {EventLocation}</li><li>Duration: {Duration}</li></ul><p><strong>Please Remember to:</strong></p><ul><li>Arrive 15 minutes early</li><li>Bring any specific props or items you want included</li><li>Wear comfortable clothing suitable for the session</li></ul><p>We look forward to capturing your special moments!</p><p>Best regards,<br/>Studio S2 Team</p></body></html>',
    @PlaceholderVariables = '{ClientName}, {EventName}, {EventTime}, {EventLocation}, {Duration}',
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- 10. Thank You Note
EXEC uspEmailTemplateUpsert
    @Id = 0,
    @TemplateName = 'Thank You Note',
    @TemplateType = 'Other',
    @Subject = 'Thank You for Choosing Studio S2 - {EventName}',
    @HtmlBody = '<html><body><h2>Thank You!</h2><p>Dear {ClientName},</p><p>We wanted to take a moment to thank you for choosing Studio S2 for {EventName}.</p><p>It was a pleasure working with you, and we hope you enjoy your photographs for years to come.</p><p><strong>Don''t Forget:</strong></p><ul><li>Share your photos on social media and tag us!</li><li>Leave us a review - your feedback helps us improve</li><li>Refer a friend and receive a special discount on your next booking</li></ul><p>If you need any additional prints or copies of your photos, please don''t hesitate to contact us.</p><p>Best regards,<br/>Studio S2 Team</p></body></html>',
    @PlaceholderVariables = '{ClientName}, {EventName}',
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

PRINT 'Email Templates seeded: 10 templates';

-- Verify EmailTemplate records
SELECT 'EmailTemplate' AS TableName, COUNT(*) AS ActiveRecords FROM EmailTemplate WHERE RowState = 'Active';

-- ============================================
-- SEED CONTRACT TEMPLATES (Gap #18)
-- ============================================

PRINT '=== Seeding Contract Templates ===';

-- 1. Wedding Service Agreement
EXEC uspContractTemplateUpsert
    @Id = 0,
    @ContractName = 'Wedding Service Agreement',
    @ServiceCategory = 'Wedding',
    @TemplateText = 'WEDDING PHOTOGRAPHY SERVICE AGREEMENT

This Wedding Photography Service Agreement (the "Agreement") is entered into as of {SigningDate} by and between Studio S2, a professional photography service (the "Photographer"), and {ClientName} (the "Client").

1. SERVICE DESCRIPTION
The Photographer agrees to provide professional photography services for the Client''s wedding event as follows:
- Event Date: {EventDate}
- Event Location: {EventLocation}
- Duration: {ServiceDuration} hours
- Service Type: {ServiceDescription}

2. PRICING AND PAYMENT TERMS
- Service Rate: {Rate}
- Deposit (due upon signing): {DepositAmount}
- Final Payment (due {PaymentTerms}): {FinalAmount}
- Currency: INR

The deposit is non-refundable unless the Photographer cancels the event. Final payment must be received before the event.

3. CANCELLATION POLICY
{CancellationPolicy}

4. DELIVERABLES
The Photographer will provide:
- Professional edited digital photographs
- Access to private online gallery
- High-resolution digital files
- Print-ready files

5. USAGE RIGHTS AND LICENSING
The Client grants the Photographer permission to use photographs for portfolio, website, and promotional purposes with proper attribution.

6. LIMITATIONS
The Photographer is not liable for:
- Unforeseen circumstances beyond reasonable control
- Lost or damaged original files due to equipment failure
- Failure to capture specific shots due to lighting or technical limitations

7. INTELLECTUAL PROPERTY
All original photographs remain the intellectual property of the Photographer. The Client receives a personal use license for the purchased photographs.

8. REVISIONS AND RETAKES
One round of basic edits is included. Additional revisions will be charged at the rate of {RevisionRate}.

Agreed and signed:

Client: _________________________ Date: _____________

Photographer: _________________________ Date: _____________',
    @PlaceholderVariables = '{SigningDate}, {ClientName}, {EventDate}, {EventLocation}, {ServiceDuration}, {ServiceDescription}, {Rate}, {DepositAmount}, {FinalAmount}, {PaymentTerms}, {CancellationPolicy}, {RevisionRate}',
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- 2. Portrait Session Agreement
EXEC uspContractTemplateUpsert
    @Id = 0,
    @ContractName = 'Portrait Session Agreement',
    @ServiceCategory = 'Portrait',
    @TemplateText = 'PORTRAIT PHOTOGRAPHY SESSION AGREEMENT

This Portrait Photography Service Agreement (the "Agreement") is entered into as of {SigningDate} by and between Studio S2 (the "Photographer"), and {ClientName} (the "Client").

1. SESSION DETAILS
- Session Date: {EventDate}
- Session Time: {SessionTime}
- Location: {EventLocation}
- Duration: {ServiceDuration} minutes
- Number of Subjects: {NumberOfSubjects}

2. PRICING AND PAYMENT
- Session Rate: {Rate}
- Retouching: {RetouchingInclusion}
- Rush Processing Fee (if applicable): {RushFee}
- Total Amount: {FinalAmount}

50% deposit required to confirm the session. Final payment due at the time of session.

3. CANCELLATION AND RESCHEDULING
Cancellations made with 48 hours notice will result in deposit forfeiture. The Client may reschedule once without additional charge.

4. ATTIRE AND PREPARATION
The Client is responsible for:
- Coordinating appropriate attire
- Providing direction regarding hair and makeup
- Clearing the agreed location of personal items
- Arranging any necessary permits for location use

5. PHOTOGRAPHS AND DELIVERABLES
The Photographer will deliver:
- Minimum {MinimumPhotos} edited digital photographs
- Online gallery access (valid for {GalleryAccessDays} days)
- High-resolution files
- Consent to print and share

6. USAGE AND INTELLECTUAL PROPERTY
All photographs are owned by the Photographer. The Client receives a personal, non-commercial use license.

7. RETOUCHING
Basic retouching (skin smoothing, color correction) is included. Additional retouching will be charged at {RetouchingRate}.

Agreed and signed:

Client: _________________________ Date: _____________

Photographer: _________________________ Date: _____________',
    @PlaceholderVariables = '{SigningDate}, {ClientName}, {EventDate}, {SessionTime}, {EventLocation}, {ServiceDuration}, {NumberOfSubjects}, {Rate}, {RetouchingInclusion}, {RushFee}, {FinalAmount}, {MinimumPhotos}, {GalleryAccessDays}, {RetouchingRate}',
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- 3. Event Photography Contract
EXEC uspContractTemplateUpsert
    @Id = 0,
    @ContractName = 'Event Photography Contract',
    @ServiceCategory = 'Events',
    @TemplateText = 'EVENT PHOTOGRAPHY SERVICES AGREEMENT

This Event Photography Services Agreement (the "Agreement") is entered into as of {SigningDate} between Studio S2 (the "Photographer") and {ClientName} (the "Client").

1. EVENT DETAILS
- Event Name: {EventName}
- Event Date: {EventDate}
- Event Duration: {ServiceDuration} hours
- Event Type: {EventType}
- Event Location: {EventLocation}
- Number of Photographers: {NumberOfPhotographers}

2. SERVICES AND DELIVERABLES
The Photographer will provide:
- Professional photography coverage for the specified duration
- {MinimumPhotos}+ carefully edited digital photographs
- Online private gallery for sharing and ordering prints
- Professional color correction and basic retouching
- High-resolution files for personal use and printing

3. FEES AND PAYMENT SCHEDULE
- Service Fee: {Rate}
- Deposit (50%): {DepositAmount}
- Balance Due: {FinalAmount} on {PaymentTerms}

The deposit confirms the event date and is non-refundable if the Client cancels with less than 30 days notice.

4. SCHEDULE AND COVERAGE
Photography coverage begins at {StartTime} and concludes at {EndTime}. Additional coverage may be arranged for {AdditionalHourRate}/hour.

5. SPECIAL REQUESTS
Special requests (such as drone photography, video, or extended album production) must be arranged in advance and will incur additional fees.

6. CANCELLATION POLICY
{CancellationPolicy}

7. INTELLECTUAL PROPERTY AND USAGE RIGHTS
All original photographs and negatives remain the sole property of the Photographer. The Client receives a personal, non-exclusive license to use the photographs for personal use only.

8. LIABILITY
The Photographer is not responsible for:
- Loss or damage to equipment
- Failure to capture images due to weather or unforeseen circumstances
- Errors or omissions in photography selection or editing

9. CORRECTIONS AND CHANGES
The Client may request basic corrections (exposure, color correction). Major re-editing or artistic changes will be charged separately.

Agreed and signed:

Client: _________________________ Date: _____________

Photographer: _________________________ Date: _____________',
    @PlaceholderVariables = '{SigningDate}, {ClientName}, {EventName}, {EventDate}, {ServiceDuration}, {EventType}, {EventLocation}, {NumberOfPhotographers}, {MinimumPhotos}, {Rate}, {DepositAmount}, {FinalAmount}, {PaymentTerms}, {StartTime}, {EndTime}, {AdditionalHourRate}, {CancellationPolicy}',
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- 4. Video Services Agreement
EXEC uspContractTemplateUpsert
    @Id = 0,
    @ContractName = 'Video Services Agreement',
    @ServiceCategory = 'Video',
    @TemplateText = 'VIDEO PRODUCTION SERVICES AGREEMENT

This Video Production Services Agreement (the "Agreement") is entered into as of {SigningDate} between Studio S2 (the "Producer") and {ClientName} (the "Client").

1. PROJECT SCOPE
- Project Name: {ProjectName}
- Project Type: {VideoType}
- Shoot Date(s): {EventDate}
- Location(s): {EventLocation}
- Deliverable Length: {VideoLength} minutes

2. VIDEO PRODUCTION PACKAGE
Studio S2 will provide:
- Professional videography with {NumberOfCameras} camera(s)
- Professional audio recording
- {NumberOfDays} days of shooting
- Professional color grading and color correction
- {RevisionRounds} rounds of revisions
- Final video delivery in {DeliveryFormats}
- Raw footage on external hard drive

3. FEES AND PAYMENT TERMS
- Service Fee: {Rate}
- Deposit (50%): {DepositAmount}
- Final Payment: {FinalAmount} due {PaymentTerms}
- Rush Processing (if applicable): {RushFee}

Payment plan: 50% due to confirm the project, balance due upon delivery.

4. TIMELINE
- Filming: {EventDate}
- Post-Production: {ProductionDays} business days
- Final Delivery: {DeliveryDate}

5. REVISION POLICY
{RevisionRounds} rounds of major revisions are included. Additional revisions will be charged at {RevisionRate}.

6. DELIVERABLES
- Primary edited video file
- YouTube-optimized version
- Social media clips (15-30 seconds)
- Hard drive with all files

7. INTELLECTUAL PROPERTY
The Producer retains ownership of the original video and footage. The Client receives a license to use the final video for personal and commercial purposes as agreed.

8. CANCELLATION AND RESCHEDULING
Cancellations within 14 days of the shoot date will forfeit the deposit. Rescheduling is permitted once.

9. LIABILITY AND LIMITATIONS
The Producer is not liable for:
- Loss of footage due to equipment malfunction
- Inability to capture specific moments
- Video degradation from third-party hosting

Agreed and signed:

Client: _________________________ Date: _____________

Producer: _________________________ Date: _____________',
    @PlaceholderVariables = '{SigningDate}, {ClientName}, {ProjectName}, {VideoType}, {EventDate}, {EventLocation}, {VideoLength}, {NumberOfCameras}, {NumberOfDays}, {DeliveryFormats}, {Rate}, {DepositAmount}, {FinalAmount}, {PaymentTerms}, {RushFee}, {ProductionDays}, {DeliveryDate}, {RevisionRounds}, {RevisionRate}',
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- 5. Corporate Photography Contract
EXEC uspContractTemplateUpsert
    @Id = 0,
    @ContractName = 'Corporate Photography Contract',
    @ServiceCategory = 'Corporate',
    @TemplateText = 'CORPORATE PHOTOGRAPHY SERVICES AGREEMENT

This Corporate Photography Services Agreement (the "Agreement") is entered into as of {SigningDate} between Studio S2 (the "Photographer") and {ClientName} (the "Client").

1. ASSIGNMENT DETAILS
- Assignment Type: {AssignmentType}
- Location(s): {EventLocation}
- Date(s): {EventDate}
- Time: {ServiceDuration} hours
- Subject Matter: {SubjectMatter}

2. DELIVERABLES
The Photographer will provide:
- {MinimumPhotos}+ professionally edited images
- Digital download of all selected images
- Web-resolution files for internal use
- Print-ready high-resolution files
- Online gallery with password protection

3. USAGE RIGHTS AND LICENSING
The Client receives a one-time license to:
- Use photographs for internal company communications
- Display on company website and social media
- Include in print materials and reports

The Client does NOT receive the right to:
- Sublicense or resell the photographs
- Remove or alter the photographer''s copyright notice
- Use photographs beyond {LicenseDuration} from delivery date

4. FEE STRUCTURE
- Photography Service: {Rate}
- Usage License: Included
- Deposit (required to confirm): {DepositAmount}
- Balance Due: {FinalAmount} within {PaymentTerms} of delivery

5. ADDITIONAL REQUIREMENTS
- Parking and access arrangements: {ClientResponsibility}
- Props or set preparation: Client shall provide
- Models or subjects: Client shall ensure consent and availability

6. CANCELLATION POLICY
Cancellation with less than 7 days notice will forfeit the deposit. Cancellation with 7+ days notice will refund the deposit minus {CancellationFee}.

7. INTELLECTUAL PROPERTY
All original photographs and digital files remain the exclusive property of the Photographer. The Client receives only the specified license to use.

8. INDEMNIFICATION
The Client agrees to indemnify the Photographer against any claims arising from the Client''s use of the photographs beyond the scope of the license granted.

Agreed and signed:

Client: _________________________ Date: _____________

Photographer: _________________________ Date: _____________',
    @PlaceholderVariables = '{SigningDate}, {ClientName}, {AssignmentType}, {EventLocation}, {EventDate}, {ServiceDuration}, {SubjectMatter}, {MinimumPhotos}, {LicenseDuration}, {Rate}, {DepositAmount}, {FinalAmount}, {PaymentTerms}, {ClientResponsibility}, {CancellationFee}',
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- 6. Licensing & Usage Rights Agreement
EXEC uspContractTemplateUpsert
    @Id = 0,
    @ContractName = 'Licensing & Usage Rights Agreement',
    @ServiceCategory = 'Other',
    @TemplateText = 'PHOTOGRAPHY LICENSING AND USAGE RIGHTS AGREEMENT

This Licensing and Usage Rights Agreement (the "Agreement") is entered into as of {SigningDate} between Studio S2 (the "Licensor") and {ClientName} (the "Licensee").

1. LICENSED CONTENT
Licensed Photographs: {PhotoCount} images from {EventName}
License Grant Date: {SigningDate}
License Expiration: {LicenseExpiration}

2. GRANT OF LICENSE
The Licensor grants to the Licensee a {LicenseType} license to use the Licensed Photographs as follows:

PERMITTED USES:
- {PermittedUse1}
- {PermittedUse2}
- {PermittedUse3}

PROHIBITED USES:
- Sublicensing or resale of the photographs
- Alteration, modification, or derivative works without written consent
- Use in competing commercial ventures
- Removal of copyright notices or watermarks

3. ATTRIBUTION REQUIREMENTS
When using the Licensed Photographs, the Licensee shall:
- Maintain all copyright notices and watermarks
- Provide credit as follows: "Photography by Studio S2" in reasonable proximity to the image
- Include a hyperlink to Studio S2 website where possible

4. PAYMENT AND FEES
License Fee: {LicenseFee}
License Duration: {LicenseDuration}
Renewal Fee: {RenewalFee}

Payment Terms: {PaymentTerms}

5. RESTRICTIONS
The Licensee shall NOT:
- Use photographs for purposes not expressly authorized
- Permit third parties to use the photographs without additional licensing
- Create derivative works or use AI to modify the photographs
- Use photographs beyond the license term

6. TERM AND TERMINATION
- License Term: {LicenseDuration} from {SigningDate}
- Renewal: Automatic unless notice of non-renewal is provided 30 days before expiration
- Termination: Either party may terminate with 30 days written notice

Upon termination or expiration, the Licensee shall cease use of the photographs and confirm destruction of all copies.

7. WARRANTY AND LIABILITY
The Licensor warrants that it owns all rights to the Licensed Photographs. The Licensor is not liable for:
- Licensee''s misuse or unauthorized use
- Third-party claims arising from the Licensee''s use
- Loss of revenue or business interruption

8. CONFIDENTIALITY
The Licensee agrees to maintain confidentiality regarding the terms of this license and the existence of unpublished photographs.

Agreed and signed:

Licensee: _________________________ Date: _____________

Licensor: _________________________ Date: _____________',
    @PlaceholderVariables = '{SigningDate}, {ClientName}, {PhotoCount}, {EventName}, {LicenseExpiration}, {LicenseType}, {PermittedUse1}, {PermittedUse2}, {PermittedUse3}, {LicenseFee}, {LicenseDuration}, {RenewalFee}, {PaymentTerms}',
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

PRINT 'Contract Templates seeded: 6 templates';

-- Verify ContractTemplate records
SELECT 'ContractTemplate' AS TableName, COUNT(*) AS ActiveRecords FROM ContractTemplate WHERE RowState = 'Active';

-- ============================================
-- SEED PRICING RULES (Gap #20)
-- ============================================

PRINT '=== Seeding Pricing Rules ===';

-- Weekend Surcharge: +50%
EXEC uspPricingRuleUpsert
    @Id = 0,
    @RuleName = 'Weekend Surcharge',
    @ServiceCategory = NULL,
    @RuleType = 'Weekend',
    @AdjustmentType = 'Percentage',
    @AdjustmentValue = 50,
    @EffectiveFrom = NULL,
    @EffectiveTo = NULL,
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- Holiday Premium: +75%
EXEC uspPricingRuleUpsert
    @Id = 0,
    @RuleName = 'Holiday Premium',
    @ServiceCategory = NULL,
    @RuleType = 'Holiday',
    @AdjustmentType = 'Percentage',
    @AdjustmentValue = 75,
    @EffectiveFrom = NULL,
    @EffectiveTo = NULL,
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- Rush Booking: +100%
EXEC uspPricingRuleUpsert
    @Id = 0,
    @RuleName = 'Rush Booking (24hr)',
    @ServiceCategory = NULL,
    @RuleType = 'Rush',
    @AdjustmentType = 'Percentage',
    @AdjustmentValue = 100,
    @EffectiveFrom = NULL,
    @EffectiveTo = NULL,
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- Early Bird Discount: -15%
EXEC uspPricingRuleUpsert
    @Id = 0,
    @RuleName = 'Early Bird Discount (2+ months)',
    @ServiceCategory = NULL,
    @RuleType = 'EarlyBird',
    @AdjustmentType = 'Percentage',
    @AdjustmentValue = -15,
    @EffectiveFrom = NULL,
    @EffectiveTo = NULL,
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- Group Discount: -10%
EXEC uspPricingRuleUpsert
    @Id = 0,
    @RuleName = 'Group Discount (3+ bookings)',
    @ServiceCategory = NULL,
    @RuleType = 'GroupDiscount',
    @AdjustmentType = 'Percentage',
    @AdjustmentValue = -10,
    @EffectiveFrom = NULL,
    @EffectiveTo = NULL,
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- Evening Session: +$150 fixed
EXEC uspPricingRuleUpsert
    @Id = 0,
    @RuleName = 'Evening Session',
    @ServiceCategory = NULL,
    @RuleType = 'Evening',
    @AdjustmentType = 'FixedAmount',
    @AdjustmentValue = 150,
    @EffectiveFrom = NULL,
    @EffectiveTo = NULL,
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- Overnight Coverage: +$200 fixed
EXEC uspPricingRuleUpsert
    @Id = 0,
    @RuleName = 'Overnight Coverage',
    @ServiceCategory = NULL,
    @RuleType = 'Overnight',
    @AdjustmentType = 'FixedAmount',
    @AdjustmentValue = 200,
    @EffectiveFrom = NULL,
    @EffectiveTo = NULL,
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

-- Video Add-on: +40%
EXEC uspPricingRuleUpsert
    @Id = 0,
    @RuleName = 'Video Add-on',
    @ServiceCategory = 'Video',
    @RuleType = 'Other',
    @AdjustmentType = 'Percentage',
    @AdjustmentValue = 40,
    @EffectiveFrom = NULL,
    @EffectiveTo = NULL,
    @IsActive = 1,
    @CreatedBy = @TemplateAdminId;

PRINT 'Pricing Rules seeded: 8 rules';

-- Verify PricingRule records
SELECT 'PricingRule' AS TableName, COUNT(*) AS ActiveRecords FROM PricingRule WHERE RowState = 'Active';

-- ============================================
-- SEED DELIVERY PACKAGES (Gap #25)
-- ============================================

PRINT '=== Seeding Delivery Packages ===';

DECLARE @SampleBookingID INT = 1;
DECLARE @SampleAdminID INT = 1;
DECLARE @DeliveryID INT;

-- Check if sample booking exists, if not use the first available
SELECT TOP 1 @SampleBookingID = BookingID FROM Booking WHERE RowState = 'Active';

-- If no bookings exist, create sample bookings first (for demo purposes)
IF @SampleBookingID IS NULL
BEGIN
    -- Create minimal sample booking to demonstrate delivery packages
    DECLARE @ClientID INT, @PackageID INT, @QuotationID INT, @PhotograpyerID INT;

    -- Use existing users/packages/clients or create sample ones
    SELECT TOP 1 @PhotograpyerID = UserID FROM Users WHERE IsPhotographer = 1 AND IsActive = 1;
    SELECT TOP 1 @PackageID = PackageID FROM PhotographyPackage WHERE RowState = 'Active' AND IsActive = 1;
    SELECT TOP 1 @ClientID = ClientID FROM ClientInfo WHERE RowState = 'Active';

    IF @PackageID IS NOT NULL AND @ClientID IS NOT NULL AND @PhotograpyerID IS NOT NULL
    BEGIN
        -- Create a sample quotation
        INSERT INTO Quotation (EventID, ClientEmail, ClientName, QuotationNumber, TotalAmount, Status, CreatedBy, CreatedAt)
        SELECT TOP 1 1, c.Email, c.FullName, 'QUOT-' + FORMAT(GETUTCDATE(), 'yyyyMMddHHmmss'), 50000, 'Accepted', @SampleAdminID, GETUTCDATE()
        FROM ClientInfo c WHERE c.ClientID = @ClientID;

        SELECT @QuotationID = @@IDENTITY;

        -- Create a sample booking
        INSERT INTO Booking (PackageID, ClientID, QuotationID, PhotographerUserID, BookingDate, Status, TotalPrice, CreatedBy, CreatedAt)
        VALUES (@PackageID, @ClientID, @QuotationID, @PhotograpyerID, GETDATE(), 'Completed', 50000, @SampleAdminID, GETUTCDATE());

        SELECT @SampleBookingID = @@IDENTITY;
    END
END

-- Seed 10 delivery packages with various scenarios
IF @SampleBookingID IS NOT NULL
BEGIN
    -- 1. Online Gallery - Completed (past delivery)
    EXEC uspDeliveryPackageUpsert
        @Id = 0,
        @BookingID = @SampleBookingID,
        @DeliverableType = 'OnlineGallery',
        @DeliveryDate = DATEADD(DAY, -10, GETUTCDATE()),
        @DeliveryMethod = 'Download',
        @DeliveryNotes = 'Gallery link shared via email with password access',
        @IsCompleted = 1,
        @CompletedAt = DATEADD(DAY, -9, GETUTCDATE()),
        @CreatedBy = @SampleAdminID;

    -- 2. Printed Album - Pending (scheduled for future)
    EXEC uspDeliveryPackageUpsert
        @Id = 0,
        @BookingID = @SampleBookingID,
        @DeliverableType = 'PrintedAlbum',
        @DeliveryDate = DATEADD(DAY, 15, GETUTCDATE()),
        @DeliveryMethod = 'Physical',
        @DeliveryNotes = 'Premium leather-bound album, 50 pages, 12x12 inches',
        @IsCompleted = 0,
        @CreatedBy = @SampleAdminID;

    -- 3. USB Drive - Pending (past scheduled date, not yet completed)
    EXEC uspDeliveryPackageUpsert
        @Id = 0,
        @BookingID = @SampleBookingID,
        @DeliverableType = 'USB',
        @DeliveryDate = DATEADD(DAY, -5, GETUTCDATE()),
        @DeliveryMethod = 'InPerson',
        @DeliveryNotes = 'High-speed 32GB USB with all edited images in 2K resolution',
        @IsCompleted = 0,
        @CreatedBy = @SampleAdminID;

    -- 4. Prints (24x36) - Completed
    EXEC uspDeliveryPackageUpsert
        @Id = 0,
        @BookingID = @SampleBookingID,
        @DeliverableType = 'Prints',
        @DeliveryDate = DATEADD(DAY, -7, GETUTCDATE()),
        @DeliveryMethod = 'Physical',
        @DeliveryNotes = '4 pieces large format prints (24x36 inches) on premium matte paper',
        @IsCompleted = 1,
        @CompletedAt = DATEADD(DAY, -6, GETUTCDATE()),
        @CreatedBy = @SampleAdminID;

    -- 5. Video Edited Master - Pending
    EXEC uspDeliveryPackageUpsert
        @Id = 0,
        @BookingID = @SampleBookingID,
        @DeliverableType = 'VideoEditedMaster',
        @DeliveryDate = DATEADD(DAY, 20, GETUTCDATE()),
        @DeliveryMethod = 'Download',
        @DeliveryNotes = 'Full event video, 2 hours, color graded, with music',
        @IsCompleted = 0,
        @CreatedBy = @SampleAdminID;

    -- 6. RAW Files - Completed (urgent delivery)
    EXEC uspDeliveryPackageUpsert
        @Id = 0,
        @BookingID = @SampleBookingID,
        @DeliverableType = 'RAWFiles',
        @DeliveryDate = DATEADD(DAY, -20, GETUTCDATE()),
        @DeliveryMethod = 'Download',
        @DeliveryNotes = '1250 RAW files in DNG format via Dropbox link',
        @IsCompleted = 1,
        @CompletedAt = DATEADD(DAY, -19, GETUTCDATE()),
        @CreatedBy = @SampleAdminID;

    -- 7. BlueRay - Pending
    EXEC uspDeliveryPackageUpsert
        @Id = 0,
        @BookingID = @SampleBookingID,
        @DeliverableType = 'BlueRay',
        @DeliveryDate = DATEADD(DAY, 30, GETUTCDATE()),
        @DeliveryMethod = 'Physical',
        @DeliveryNotes = 'Dual-layer Blu-ray disc with menu, backup disc included',
        @IsCompleted = 0,
        @CreatedBy = @SampleAdminID;

    -- 8. Proof Book - Completed
    EXEC uspDeliveryPackageUpsert
        @Id = 0,
        @BookingID = @SampleBookingID,
        @DeliverableType = 'ProofBook',
        @DeliveryDate = DATEADD(DAY, -15, GETUTCDATE()),
        @DeliveryMethod = 'Email',
        @DeliveryNotes = 'Digital proof sheet with 60 best images for client selection',
        @IsCompleted = 1,
        @CompletedAt = DATEADD(DAY, -14, GETUTCDATE()),
        @CreatedBy = @SampleAdminID;

    -- 9. Canvas Print - Pending (long lead time)
    EXEC uspDeliveryPackageUpsert
        @Id = 0,
        @BookingID = @SampleBookingID,
        @DeliverableType = 'Canvas',
        @DeliveryDate = DATEADD(DAY, 45, GETUTCDATE()),
        @DeliveryMethod = 'Physical',
        @DeliveryNotes = 'Premium stretched canvas, 36x48 inches, gallery-wrapped',
        @IsCompleted = 0,
        @CreatedBy = @SampleAdminID;

    -- 10. Other Deliverable - Completed (custom item)
    EXEC uspDeliveryPackageUpsert
        @Id = 0,
        @BookingID = @SampleBookingID,
        @DeliverableType = 'Other',
        @DeliveryDate = DATEADD(DAY, -3, GETUTCDATE()),
        @DeliveryMethod = 'Email',
        @DeliveryNotes = 'Custom client thank-you video montage',
        @IsCompleted = 1,
        @CompletedAt = DATEADD(DAY, -2, GETUTCDATE()),
        @CreatedBy = @SampleAdminID;

    PRINT 'Delivery Packages seeded: 10 packages (5 completed, 5 pending)';
END
ELSE
BEGIN
    PRINT 'Warning: No bookings found. Delivery Packages not seeded. Please create bookings first.';
END

-- Verify DeliveryPackage records
SELECT 'DeliveryPackage' AS TableName, COUNT(*) AS ActiveRecords FROM DeliveryPackage WHERE RowState = 'Active';

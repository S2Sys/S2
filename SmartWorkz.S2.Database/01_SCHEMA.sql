-- STUDIOS2 Database Schema - Clean Architecture with UPSERT Pattern
-- 36 Tables for Photography Portfolio & Booking System with Role-Based Auth, Campaigns & Offers

-- ============================================
-- AUTHENTICATION & AUTHORIZATION
-- ============================================

CREATE TABLE Roles (
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETUTCDATE()
);

CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Email NVARCHAR(255) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(20),
    Bio NVARCHAR(MAX),
    ProfilePhotoUrl NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),

    -- Photographer Fields
    IsPhotographer BIT DEFAULT 0,
    HourlyRate DECIMAL(10,2),
    DailyRate DECIMAL(10,2),
    MaxBookingsPerMonth INT,
    PreferredWorkingHours NVARCHAR(500),

    INDEX IDX_Users_IsPhotographer (IsPhotographer)
);

CREATE TABLE UserRoles (
    UserRoleID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT NOT NULL,
    RoleID INT NOT NULL,
    AssignedAt DATETIME DEFAULT GETUTCDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID),
    UNIQUE(UserID, RoleID)
);

CREATE TABLE Settings (
    SettingID INT PRIMARY KEY IDENTITY(1,1),
    SettingKey NVARCHAR(100) NOT NULL UNIQUE,
    SettingValue NVARCHAR(MAX),
    UpdatedAt DATETIME DEFAULT GETUTCDATE()
);

-- ============================================
-- EVENTS (Client Galleries & Invitations)
-- ============================================

CREATE TABLE Event (
    EventID INT PRIMARY KEY IDENTITY(1,1),
    EventName NVARCHAR(255) NOT NULL,
    EventDate DATETIME NOT NULL,
    Location NVARCHAR(500),
    Description NVARCHAR(MAX),
    Status NVARCHAR(50) DEFAULT 'Scheduled',
    EventType NVARCHAR(100),
    CreatedBy INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedBy INT,
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CHECK (Status IN ('Scheduled', 'In Progress', 'Completed', 'Cancelled')),
    CONSTRAINT CHK_Event_EventType CHECK (EventType IN ('Wedding', 'Portrait', 'Corporate', 'Personal', 'Other')),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_Event_UpdatedBy (UpdatedBy),
    INDEX IDX_Event_EventType (EventType),
    INDEX IDX_Event_IsDeleted (IsDeleted)
);

-- ============================================
-- LOCATION-BASED PRICING (Phase 2)
-- ============================================

CREATE TABLE LocationFee (
    LocationFeeID INT PRIMARY KEY IDENTITY(1,1),
    LocationName NVARCHAR(255) NOT NULL,
    City NVARCHAR(100),
    State NVARCHAR(50),
    ZipCode NVARCHAR(20),
    TravelMinutes INT,
    SurchargeAmount DECIMAL(10,2) NOT NULL,
    SurchargeType NVARCHAR(50),
    IsActive BIT DEFAULT 1,
    CreatedBy INT,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedBy INT,
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CHECK (SurchargeAmount >= 0),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_LocationFee_City (City),
    INDEX IDX_LocationFee_IsActive (IsActive),
    INDEX IDX_LocationFee_IsDeleted (IsDeleted)
);

-- ============================================
-- COMMUNICATION (Generic for Any Entity)
-- ============================================

CREATE TABLE Communication (
    CommunicationID INT PRIMARY KEY IDENTITY(1,1),

    -- What entity is this about?
    EntityType NVARCHAR(50) NOT NULL,     -- Event, Booking, Quotation, Invoice, Gallery, Package
    EntityID INT NOT NULL,                -- ID of that entity

    -- Who is communicating?
    FromUserID INT NOT NULL,              -- Photographer/admin sending
    ToClientID INT,                       -- Client receiving (optional)
    ToEmail NVARCHAR(255) NOT NULL,       -- Email address

    -- Message content
    Subject NVARCHAR(255),
    Message NVARCHAR(MAX) NOT NULL,
    MessageType NVARCHAR(50) NOT NULL,    -- Email, SMS, Note, InApp

    -- Status tracking
    Status NVARCHAR(50) DEFAULT 'Sent',   -- Sent, Delivered, Read, Failed, Pending

    -- Metadata
    IsInternal BIT DEFAULT 0,             -- Internal note only, not sent to client
    IsAutomatic BIT DEFAULT 0,            -- Auto-generated (confirmation, reminder)
    TemplateUsed NVARCHAR(255),           -- Which template was used

    -- Timestamps
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    SentAt DATETIME,
    DeliveredAt DATETIME,
    ReadAt DATETIME,

    -- Audit trail
    CreatedBy INT NOT NULL,
    UpdatedBy INT,
    UpdatedAt DATETIME,
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,

    -- Foreign keys
    FOREIGN KEY (FromUserID) REFERENCES Users(UserID),
    FOREIGN KEY (ToClientID) REFERENCES ClientInfo(ClientID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),

    -- Constraints
    CONSTRAINT CHK_Communication_EntityType CHECK (EntityType IN ('Event', 'Booking', 'Quotation', 'Invoice', 'Gallery', 'Package', 'Payment')),
    CONSTRAINT CHK_Communication_MessageType CHECK (MessageType IN ('Email', 'SMS', 'Note', 'InApp')),
    CONSTRAINT CHK_Communication_Status CHECK (Status IN ('Pending', 'Sent', 'Delivered', 'Read', 'Failed')),
    CONSTRAINT CHK_Communication_IsDeleted CHECK (IsDeleted IN (0, 1)),

    -- Indexes for common queries
    INDEX IDX_Communication_EntityType (EntityType, EntityID),
    INDEX IDX_Communication_ToEmail (ToEmail),
    INDEX IDX_Communication_Status (Status),
    INDEX IDX_Communication_CreatedAt (CreatedAt),
    INDEX IDX_Communication_IsDeleted (IsDeleted),
    INDEX IDX_Communication_FromUserID (FromUserID),
    INDEX IDX_Communication_ToClientID (ToClientID)
);

-- ============================================
-- QUOTATIONS & CLIENT COMMUNICATION
-- ============================================

CREATE TABLE Quotation (
    QuotationID INT PRIMARY KEY IDENTITY(1,1),
    EventID INT NOT NULL,
    ClientEmail NVARCHAR(255) NOT NULL,
    ClientName NVARCHAR(255),
    QuotationNumber NVARCHAR(50) NOT NULL UNIQUE,
    QuotationDate DATETIME DEFAULT GETUTCDATE(),
    ValidUntil DATETIME,
    SubTotal DECIMAL(10,2),
    TaxAmount DECIMAL(10,2) DEFAULT 0,
    TotalAmount DECIMAL(10,2) NOT NULL,
    Status NVARCHAR(50) DEFAULT 'Draft',
    Notes NVARCHAR(MAX),
    CreatedBy INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedBy INT,
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),

    -- Engagement Tracking
    ViewedAt DATETIME,
    AcceptedAt DATETIME,
    DeclinedAt DATETIME,
    RejectionReason NVARCHAR(500),

    -- Soft Delete
    IsDeleted BIT DEFAULT 0,
    DeletedAt DATETIME,
    DeletedBy INT,

    FOREIGN KEY (EventID) REFERENCES Event(EventID) ON DELETE CASCADE,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CHECK (Status IN ('Draft', 'Sent', 'Accepted', 'Rejected', 'Converted')),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_Quotation_UpdatedBy (UpdatedBy),
    INDEX IDX_Quotation_IsDeleted (IsDeleted)
);

CREATE TABLE QuotationItem (
    ItemID INT PRIMARY KEY IDENTITY(1,1),
    QuotationID INT NOT NULL,
    ItemDescription NVARCHAR(MAX) NOT NULL,
    Quantity INT DEFAULT 1,
    UnitPrice DECIMAL(10,2) NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    DisplayOrder INT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    FOREIGN KEY (QuotationID) REFERENCES Quotation(QuotationID) ON DELETE CASCADE
);

CREATE TABLE Tag (
    TagID INT PRIMARY KEY IDENTITY(1,1),
    TagName NVARCHAR(100) NOT NULL,
    TagType NVARCHAR(50) NOT NULL,
    CreatedByUserID INT,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    FOREIGN KEY (CreatedByUserID) REFERENCES Users(UserID),
    UNIQUE(TagName, TagType)
);

CREATE TABLE EntityTag (
    EntityTagID INT PRIMARY KEY IDENTITY(1,1),
    TagID INT NOT NULL,
    EntityType NVARCHAR(50) NOT NULL,
    EntityID INT NOT NULL,
    AssignedAt DATETIME DEFAULT GETUTCDATE(),
    FOREIGN KEY (TagID) REFERENCES Tag(TagID) ON DELETE CASCADE,
    UNIQUE(TagID, EntityType, EntityID)
);

-- ============================================
-- PAYMENT METHODS (Lookup Table)
-- ============================================

-- PaymentMethod: Lookup table with system-seeded payment methods for all payment processing
CREATE TABLE PaymentMethod (
    PaymentMethodID INT PRIMARY KEY IDENTITY(1,1),
    MethodName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETUTCDATE()
);

-- Seed PaymentMethod table
INSERT INTO PaymentMethod (MethodName, Description, IsActive) VALUES
('Credit Card', 'Visa, Mastercard, Amex', 1),
('Debit Card', 'Debit card payments', 1),
('Bank Transfer', 'Direct bank transfer', 1),
('Wire Transfer', 'International wire transfer', 1),
('Check', 'Check payment', 1),
('Cash', 'Cash payment on site', 1),
('PayPal', 'PayPal payment gateway', 1),
('Stripe', 'Stripe payment processor', 1),
('Square', 'Square payment processor', 1),
('Other', 'Other payment method', 1);

-- ============================================
-- PAYMENT & FINANCIAL TRACKING
-- ============================================

CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    InvoiceID INT NOT NULL,
    BookingID INT,
    Amount DECIMAL(10,2) NOT NULL,
    Status NVARCHAR(50) DEFAULT 'Pending',
    PaymentMethod NVARCHAR(50),
    PaymentMethodID INT,
    TransactionID NVARCHAR(255),
    ProcessedAt DATETIME,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),
    FOREIGN KEY (InvoiceID) REFERENCES Invoice(InvoiceID),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID),
    FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethod(PaymentMethodID),
    CHECK (Status IN ('Pending', 'Completed', 'Failed', 'Refunded'))
);

-- ============================================
-- BOOKING GALLERY MAPPING
-- ============================================

CREATE TABLE BookingGallery (
    BookingGalleryID INT PRIMARY KEY IDENTITY(1,1),
    BookingID INT NOT NULL,
    GalleryID INT NOT NULL,
    IsDeliveryGallery BIT DEFAULT 1,
    AvailableFrom DATETIME,
    AvailableUntil DATETIME,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
    FOREIGN KEY (GalleryID) REFERENCES Gallery(GalleryID),
    UNIQUE(BookingID, GalleryID)
);

-- ============================================
-- AUDIT & CHANGE LOG
-- ============================================

CREATE TABLE ChangeLog (
    ChangeLogID INT PRIMARY KEY IDENTITY(1,1),
    EntityType NVARCHAR(100) NOT NULL,
    EntityID INT NOT NULL,
    FieldName NVARCHAR(100),
    OldValue NVARCHAR(MAX),
    NewValue NVARCHAR(MAX),
    ChangeType NVARCHAR(50),
    ChangedByUserID INT,
    Reason NVARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    FOREIGN KEY (ChangedByUserID) REFERENCES Users(UserID),
    INDEX IDX_ChangeLog_Entity (EntityType, EntityID),
    INDEX IDX_ChangeLog_CreatedAt (CreatedAt)
);

-- ============================================
-- YOUR WORK (Galleries & Assets - Consolidated)
-- Handles: Photo Galleries, Video Galleries, Image Sliders
-- ============================================

CREATE TABLE GalleryType (
    GalleryTypeID INT PRIMARY KEY IDENTITY(1,1),
    TypeName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETUTCDATE()
);

CREATE TABLE Gallery (
    GalleryID INT PRIMARY KEY IDENTITY(1,1),
    GalleryTypeID INT NOT NULL,
    EventID INT,
    Title NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX),
    Category NVARCHAR(50),
    ThumbnailUrl NVARCHAR(500),
    DisplayOrder INT DEFAULT 0,
    IsFeatured BIT DEFAULT 0,
    IsPublished BIT DEFAULT 1,
    IsPrivate BIT DEFAULT 0,
    ViewCount INT DEFAULT 0,
    RotationSpeed INT DEFAULT 5,
    StartDate DATETIME,
    EndDate DATETIME,
    ReviewStatus NVARCHAR(50) DEFAULT 'Draft',
    ClientApprovalDeadline DATETIME,
    ApprovedByUserID INT,
    CreatedBy INT,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedBy INT,
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (GalleryTypeID) REFERENCES GalleryType(GalleryTypeID),
    FOREIGN KEY (EventID) REFERENCES Event(EventID) ON DELETE SET NULL,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (ApprovedByUserID) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    -- Private galleries must be tied to an event for client access control
    CONSTRAINT CHK_Gallery_PrivateEventID CHECK ((IsPrivate = 0) OR (IsPrivate = 1 AND EventID IS NOT NULL)),
    CONSTRAINT CHK_Gallery_ReviewStatus CHECK (ReviewStatus IN ('Draft', 'UnderReview', 'ApprovedByClient', 'ReadyForDelivery', 'Delivered')),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_Gallery_UpdatedBy (UpdatedBy),
    INDEX IDX_Gallery_ReviewStatus (ReviewStatus),
    INDEX IDX_Gallery_IsDeleted (IsDeleted)
);

CREATE TABLE GalleryAsset (
    AssetID INT PRIMARY KEY IDENTITY(1,1),
    GalleryID INT NOT NULL,
    AssetType NVARCHAR(50) NOT NULL,
    MediaUrl NVARCHAR(500) NOT NULL,
    ThumbnailUrl NVARCHAR(500),
    LinkUrl NVARCHAR(500),
    AltText NVARCHAR(255),
    Caption NVARCHAR(500),
    DurationMinutes INT,
    DisplayOrder INT DEFAULT 0,
    AssetStatus NVARCHAR(50) DEFAULT 'Original',
    RetouchNotes NVARCHAR(MAX),
    CreatedBy INT NOT NULL,
    UploadedAt DATETIME DEFAULT GETUTCDATE(),
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (GalleryID) REFERENCES Gallery(GalleryID) ON DELETE CASCADE,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CONSTRAINT CHK_GalleryAsset_AssetStatus CHECK (AssetStatus IN ('Original', 'Retouched', 'Final', 'Archived', 'Rejected')),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_GalleryAsset_GalleryIDAssetType (GalleryID, AssetType),
    INDEX IDX_GalleryAsset_CreatedBy (CreatedBy),
    INDEX IDX_GalleryAsset_AssetStatus (AssetStatus),
    INDEX IDX_GalleryAsset_IsDeleted (IsDeleted)
);

CREATE TABLE GalleryAccess (
    AccessID INT PRIMARY KEY IDENTITY(1,1),
    GalleryID INT NOT NULL,
    UserID INT NOT NULL,
    AccessLevel NVARCHAR(50) DEFAULT 'View',
    CreatedBy INT,
    GrantedAt DATETIME DEFAULT GETUTCDATE(),
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (GalleryID) REFERENCES Gallery(GalleryID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CHECK (IsDeleted IN (0, 1)),
    UNIQUE(GalleryID, UserID),
    INDEX IDX_GalleryAccess_IsDeleted (IsDeleted)
);

-- ============================================
-- YOUR PACKAGES (Photography Services)
-- ============================================

CREATE TABLE PhotographyPackage (
    PackageID INT PRIMARY KEY IDENTITY(1,1),
    PackageName NVARCHAR(255) NOT NULL,
    PackageDescription NVARCHAR(MAX),
    BasePrice DECIMAL(10,2) NOT NULL,
    Currency NVARCHAR(10) DEFAULT 'INR',
    DurationHours INT,
    MaxGalleryImages INT,
    MaxVideoDurationMinutes INT,
    IncludedRawFiles BIT DEFAULT 0,
    IncludedAlbum BIT DEFAULT 0,
    IncludedRetouching BIT DEFAULT 0,
    RetouchingLevel NVARCHAR(50),
    IncludedSecondPhotographer BIT DEFAULT 0,
    ServiceCategory NVARCHAR(100),
    IsActive BIT DEFAULT 1,
    IsFeatured BIT DEFAULT 0,
    DisplayOrder INT DEFAULT 0,
    CreatedBy INT,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedBy INT,
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CONSTRAINT CHK_PhotographyPackage_ServiceCategory CHECK (ServiceCategory IN ('Wedding', 'Portrait', 'Events', 'Video', 'Corporate', 'Other')),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_PhotographyPackage_CreatedBy (CreatedBy),
    INDEX IDX_PhotographyPackage_UpdatedBy (UpdatedBy),
    INDEX IDX_PhotographyPackage_ServiceCategory (ServiceCategory),
    INDEX IDX_PhotographyPackage_IsDeleted (IsDeleted)
);

CREATE TABLE PackageComponent (
    ComponentID INT PRIMARY KEY IDENTITY(1,1),
    PackageID INT NOT NULL,
    ComponentType NVARCHAR(100),
    ComponentName NVARCHAR(255) NOT NULL,
    ComponentDescription NVARCHAR(MAX),
    Quantity INT,
    Unit NVARCHAR(50),
    AddedValue DECIMAL(10,2),
    IsIncludedByDefault BIT DEFAULT 1,
    DisplayOrder INT DEFAULT 0,
    CreatedBy INT,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedBy INT,
    UpdatedAt DATETIME,
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (PackageID) REFERENCES PhotographyPackage(PackageID) ON DELETE CASCADE,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_PackageComponent_IsDeleted (IsDeleted)
);

CREATE TABLE PackageAddOn (
    AddOnID INT PRIMARY KEY IDENTITY(1,1),
    PackageID INT NOT NULL,
    AddOnName NVARCHAR(255) NOT NULL,
    AddOnDescription NVARCHAR(MAX),
    Price DECIMAL(10,2) NOT NULL,
    Category NVARCHAR(100),
    MaxQuantity INT,
    IsFeatured BIT DEFAULT 0,
    DisplayOrder INT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedBy INT,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedBy INT,
    UpdatedAt DATETIME,
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (PackageID) REFERENCES PhotographyPackage(PackageID) ON DELETE CASCADE,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_PackageAddOn_IsDeleted (IsDeleted)
);

CREATE TABLE PackageDiscount (
    DiscountID INT PRIMARY KEY IDENTITY(1,1),
    PackageID INT NOT NULL,
    DiscountName NVARCHAR(255) NOT NULL,
    DiscountType NVARCHAR(50),
    DiscountValue DECIMAL(10,2) NOT NULL,
    ValidFrom DATETIME,
    ValidTo DATETIME,
    IsActive BIT DEFAULT 1,
    CreatedBy INT,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedBy INT,
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (PackageID) REFERENCES PhotographyPackage(PackageID) ON DELETE CASCADE,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_PackageDiscount_IsDeleted (IsDeleted)
);

-- ============================================
-- CAMPAIGNS & OFFERS
-- ============================================

CREATE TABLE Campaign (
    CampaignID INT PRIMARY KEY IDENTITY(1,1),
    CampaignName NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX),
    CampaignType NVARCHAR(50),
    StartDate DATETIME NOT NULL,
    EndDate DATETIME NOT NULL,
    BannerImageUrl NVARCHAR(500),
    DiscountType NVARCHAR(50),
    DiscountValue DECIMAL(10,2) NOT NULL,
    MaxApplicableAmount DECIMAL(10,2),
    TermsConditions NVARCHAR(MAX),
    IsActive BIT DEFAULT 1,
    DisplayOrder INT DEFAULT 0,
    CreatedBy INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedBy INT,
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CHECK (DiscountType IN ('Percentage', 'Fixed', 'BOGO', 'FreeAddon')),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_Campaign_Active (IsActive),
    INDEX IDX_Campaign_DateRange (StartDate, EndDate),
    INDEX IDX_Campaign_CreatedBy (CreatedBy),
    INDEX IDX_Campaign_IsDeleted (IsDeleted)
);

-- ============================================
-- CAMPAIGN APPLICABILITY (Phase 2)
-- ============================================

CREATE TABLE CampaignPackage (
    CampaignPackageID INT PRIMARY KEY IDENTITY(1,1),
    CampaignID INT NOT NULL,
    PackageID INT NOT NULL,
    IsApplicable BIT DEFAULT 1,
    CreatedBy INT,
    AppliedAt DATETIME DEFAULT GETUTCDATE(),
    RemovedAt DATETIME,
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (CampaignID) REFERENCES Campaign(CampaignID) ON DELETE CASCADE,
    FOREIGN KEY (PackageID) REFERENCES PhotographyPackage(PackageID) ON DELETE CASCADE,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CHECK (IsDeleted IN (0, 1)),
    UNIQUE(CampaignID, PackageID),
    INDEX IDX_CampaignPackage_Campaign (CampaignID),
    INDEX IDX_CampaignPackage_Package (PackageID),
    INDEX IDX_CampaignPackage_Applicable (IsApplicable),
    INDEX IDX_CampaignPackage_IsDeleted (IsDeleted)
);

-- ============================================
-- CLIENT BOOKINGS
-- ============================================

CREATE TABLE ClientInfo (
    ClientID INT PRIMARY KEY IDENTITY(1,1),
    Email NVARCHAR(255) NOT NULL UNIQUE,
    Phone NVARCHAR(20),
    FullName NVARCHAR(255) NOT NULL,
    Address NVARCHAR(500),
    PreferredContactMethod NVARCHAR(50),
    PreviousBookings INT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    CreatedBy INT,
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedBy INT,
    DeletedAt DATETIME,
    DeletedBy INT,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    INDEX IDX_ClientInfo_IsDeleted (IsDeleted),
    INDEX IDX_ClientInfo_CreatedBy (CreatedBy)
);

CREATE TABLE Booking (
    BookingID INT PRIMARY KEY IDENTITY(1,1),
    PackageID INT NOT NULL,
    ClientID INT NOT NULL,
    QuotationID INT NOT NULL,
    PhotographerUserID INT NOT NULL,
    BookingDate DATETIME NOT NULL,
    Location NVARCHAR(500),
    Status NVARCHAR(50) DEFAULT 'Confirmed',
    TotalPrice DECIMAL(10,2) NOT NULL,
    DepositAmount DECIMAL(10,2),
    DepositPaid BIT DEFAULT 0,
    IsDeleted BIT DEFAULT 0,
    SpecialRequests NVARCHAR(MAX),
    Notes NVARCHAR(MAX),
    CreatedBy INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedBy INT,
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),
    DeletedBy INT,
    DeletedAt DATETIME,

    -- Location & Travel
    LocationFeeID INT,
    TravelSurcharge DECIMAL(10,2) DEFAULT 0,

    FOREIGN KEY (PackageID) REFERENCES PhotographyPackage(PackageID),
    CHECK (TravelSurcharge >= 0),
    FOREIGN KEY (ClientID) REFERENCES ClientInfo(ClientID),
    FOREIGN KEY (QuotationID) REFERENCES Quotation(QuotationID),
    FOREIGN KEY (PhotographerUserID) REFERENCES Users(UserID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    FOREIGN KEY (LocationFeeID) REFERENCES LocationFee(LocationFeeID),
    CHECK (Status IN ('Confirmed', 'Scheduled', 'Completed', 'Cancelled')),
    -- Deposit is either not collected upfront (NULL) or cannot exceed total booking price
    CONSTRAINT CHK_Booking_DepositAmount CHECK (DepositAmount IS NULL OR DepositAmount <= TotalPrice),
    INDEX IDX_Booking_CreatedBy (CreatedBy),
    INDEX IDX_Booking_UpdatedBy (UpdatedBy),
    INDEX IDX_Booking_IsDeleted (IsDeleted),
    INDEX IDX_Booking_LocationFeeID (LocationFeeID)
);

CREATE TABLE BookingPackage (
    BookingPackageID INT PRIMARY KEY IDENTITY(1,1),
    BookingID INT NOT NULL,
    PackageID INT NOT NULL,
    -- CampaignID: NULL if booking is not part of a promotion/campaign
    CampaignID INT,
    SelectedAddOnsJson NVARCHAR(MAX),
    AppliedDiscount DECIMAL(10,2) DEFAULT 0,
    FinalPrice DECIMAL(10,2) NOT NULL,
    PackageSnapshot NVARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
    FOREIGN KEY (PackageID) REFERENCES PhotographyPackage(PackageID),
    FOREIGN KEY (CampaignID) REFERENCES Campaign(CampaignID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_BookingPackage_CampaignID (CampaignID),
    INDEX IDX_BookingPackage_IsDeleted (IsDeleted)
);

CREATE TABLE CalendarBlock (
    BlockID INT PRIMARY KEY IDENTITY(1,1),
    BookingID INT,
    BlockStart DATETIME NOT NULL,
    BlockEnd DATETIME NOT NULL,
    Status NVARCHAR(50) DEFAULT 'Booked',
    BlockReason NVARCHAR(255),
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE SET NULL,
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CHECK (BlockEnd > BlockStart),
    CHECK (Status IN ('Booked', 'Blocked', 'Maintenance', 'Hold')),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_CalendarBlock_IsDeleted (IsDeleted)
);

CREATE TABLE Availability (
    AvailabilityID INT PRIMARY KEY IDENTITY(1,1),
    PhotographerUserID INT NOT NULL,
    AvailabilityStart DATETIME NOT NULL,
    AvailabilityEnd DATETIME NOT NULL,
    IsAvailable BIT DEFAULT 1,
    Notes NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (PhotographerUserID) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CHECK (AvailabilityEnd > AvailabilityStart),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_Availability_PhotographerUserID (PhotographerUserID),
    INDEX IDX_Availability_IsDeleted (IsDeleted)
);

-- ============================================
-- YOUR DAILY WORK (Tasks)
-- ============================================

CREATE TABLE DailyTask (
    TaskID INT PRIMARY KEY IDENTITY(1,1),
    BookingID INT,
    Title NVARCHAR(255) NOT NULL,
    Description NVARCHAR(MAX),
    Status NVARCHAR(50) DEFAULT 'Pending',
    Priority NVARCHAR(50) DEFAULT 'Medium',
    DueDate DATETIME,
    Notes NVARCHAR(MAX),
    CreatedBy INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedBy INT,
    UpdatedAt DATETIME,
    AssignedTo INT,
    AssignedAt DATETIME,
    CompletedBy INT,
    CompletedAt DATETIME,
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE SET NULL,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (AssignedTo) REFERENCES Users(UserID),
    FOREIGN KEY (CompletedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CHECK (Status IN ('Pending', 'In Progress', 'On Hold', 'Completed', 'Cancelled')),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_DailyTask_CreatedBy (CreatedBy),
    INDEX IDX_DailyTask_AssignedTo (AssignedTo),
    INDEX IDX_DailyTask_Status_DueDate (Status, DueDate),
    INDEX IDX_DailyTask_IsDeleted (IsDeleted)
);

CREATE TABLE TaskComment (
    CommentID INT PRIMARY KEY IDENTITY(1,1),
    TaskID INT NOT NULL,
    Comment NVARCHAR(MAX) NOT NULL,
    CreatedBy INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedBy INT,
    UpdatedAt DATETIME,
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (TaskID) REFERENCES DailyTask(TaskID) ON DELETE CASCADE,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_TaskComment_TaskID_CreatedAt (TaskID, CreatedAt),
    INDEX IDX_TaskComment_CreatedBy (CreatedBy),
    INDEX IDX_TaskComment_IsDeleted (IsDeleted)
);

-- ============================================
-- BUSINESS RECORDS & ANALYTICS
-- ============================================

CREATE TABLE BookingLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    BookingID INT NOT NULL,
    Action NVARCHAR(100) NOT NULL,
    CreatedBy INT,
    Timestamp DATETIME DEFAULT GETUTCDATE(),
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_BookingLog_IsDeleted (IsDeleted)
);

CREATE TABLE ViewAnalytics (
    AnalyticsID INT PRIMARY KEY IDENTITY(1,1),
    EntityType NVARCHAR(100) NOT NULL,
    EntityID INT NOT NULL,
    ViewCount INT DEFAULT 0,
    LastViewedAt DATETIME,
    UpdatedAt DATETIME DEFAULT GETUTCDATE()
);

CREATE TABLE Invoice (
    InvoiceID INT PRIMARY KEY IDENTITY(1,1),
    BookingID INT NOT NULL,
    ClientID INT NOT NULL,
    QuotationID INT,
    InvoiceNumber NVARCHAR(50) NOT NULL UNIQUE,
    Amount DECIMAL(10,2) NOT NULL,
    TaxAmount DECIMAL(10,2) DEFAULT 0,
    TotalAmount DECIMAL(10,2) NOT NULL,
    Status NVARCHAR(50) DEFAULT 'Draft',
    IssuedDate DATETIME,
    DueDate DATETIME,
    PaidDate DATETIME,
    PdfFileUrl NVARCHAR(500),
    CreatedBy INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedBy INT,
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID),
    FOREIGN KEY (ClientID) REFERENCES ClientInfo(ClientID),
    FOREIGN KEY (QuotationID) REFERENCES Quotation(QuotationID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CHECK (Status IN ('Draft', 'Issued', 'Sent', 'Partially Paid', 'Paid', 'Overdue')),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_Invoice_ClientID (ClientID),
    INDEX IDX_Invoice_CreatedBy (CreatedBy),
    INDEX IDX_Invoice_UpdatedBy (UpdatedBy),
    INDEX IDX_Invoice_IsDeleted (IsDeleted)
);

-- ============================================
-- SEO & WEBSITE METADATA
-- ============================================

CREATE TABLE SEOMetadata (
    MetadataID INT PRIMARY KEY IDENTITY(1,1),
    PageType NVARCHAR(100) NOT NULL,
    PageID INT,
    PageTitle NVARCHAR(255),
    MetaDescription NVARCHAR(500),
    MetaKeywords NVARCHAR(MAX),
    Slug NVARCHAR(255) UNIQUE,
    CanonicalUrl NVARCHAR(500),
    OGTitle NVARCHAR(255),
    OGDescription NVARCHAR(500),
    OGImageUrl NVARCHAR(500),
    SchemaMarkup NVARCHAR(MAX),
    IsIndexed BIT DEFAULT 1,
    CreatedBy INT,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedBy INT,
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_SEOMetadata_IsDeleted (IsDeleted)
);

-- ============================================
-- ASSETS & EXPENSES
-- ============================================

CREATE TABLE Asset (
    AssetID INT PRIMARY KEY IDENTITY(1,1),
    AssetType NVARCHAR(50) NOT NULL,
    EntityType NVARCHAR(100) NOT NULL,
    EntityID INT NOT NULL,
    FilePath NVARCHAR(500) NOT NULL,
    FileName NVARCHAR(255) NOT NULL,
    FileSize BIGINT,
    MimeType NVARCHAR(100),
    Description NVARCHAR(MAX),
    UploadedByUserID INT NOT NULL,
    IsDeleted BIT DEFAULT 0,
    DeletedAt DATETIME,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),
    FOREIGN KEY (UploadedByUserID) REFERENCES Users(UserID),
    CHECK (AssetType IN ('Image', 'Video', 'Document', 'Audio', 'Other')),
    CHECK (EntityType IN ('Gallery', 'Booking', 'Invoice', 'Event', 'Profile', 'Other')),
    INDEX IDX_Asset_EntityType (EntityType, EntityID),
    INDEX IDX_Asset_AssetType (AssetType)
);

CREATE TABLE Expense (
    ExpenseID INT PRIMARY KEY IDENTITY(1,1),
    BookingID INT,
    EventID INT,
    ExpenseType NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    Amount DECIMAL(10,2) NOT NULL,
    Currency NVARCHAR(10) DEFAULT 'USD',
    Status NVARCHAR(50) DEFAULT 'Pending',
    ReceiptAssetID INT,
    CreatedByUserID INT NOT NULL,
    ApprovedByUserID INT,
    ApprovedDate DATETIME,
    IsDeleted BIT DEFAULT 0,
    DeletedAt DATETIME,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE SET NULL,
    FOREIGN KEY (EventID) REFERENCES Event(EventID) ON DELETE SET NULL,
    FOREIGN KEY (ReceiptAssetID) REFERENCES Asset(AssetID),
    FOREIGN KEY (CreatedByUserID) REFERENCES Users(UserID),
    FOREIGN KEY (ApprovedByUserID) REFERENCES Users(UserID),
    CHECK (Status IN ('Pending', 'Approved', 'Rejected', 'Paid')),
    CHECK (ExpenseType IN ('Travel', 'Equipment', 'Crew', 'Venue', 'Catering', 'Payroll', 'Other')),
    INDEX IDX_Expense_BookingID (BookingID),
    INDEX IDX_Expense_EventID (EventID),
    INDEX IDX_Expense_Status (Status),
    INDEX IDX_Expense_CreatedByUserID (CreatedByUserID),
    INDEX IDX_Expense_ExpenseType (ExpenseType)
);

-- ============================================
-- EQUIPMENT RENTAL SYSTEM (Phase 3)
-- ============================================

CREATE TABLE RentalClient (
    RentalClientID INT PRIMARY KEY IDENTITY(1,1),
    Email NVARCHAR(255) NOT NULL UNIQUE,
    Phone NVARCHAR(20),
    FullName NVARCHAR(255) NOT NULL,
    Address NVARCHAR(500),
    City NVARCHAR(100),
    State NVARCHAR(50),
    ZipCode NVARCHAR(20),
    ProfilePhotoUrl NVARCHAR(500),
    ValidIDType NVARCHAR(50),
    ValidIDNumber NVARCHAR(100),
    ValidIDPhotoUrl NVARCHAR(500),
    ValidIDExpiry DATETIME,
    IsIDVerified BIT DEFAULT 0,
    IDVerifiedBy INT,
    IDVerifiedAt DATETIME,
    TotalRentalsCount INT DEFAULT 0,
    TotalRentalSpend DECIMAL(10,2) DEFAULT 0,
    IsBlacklisted BIT DEFAULT 0,
    BlacklistedReason NVARCHAR(500),
    AllowEmailCommunication BIT DEFAULT 1,
    AllowSMSCommunication BIT DEFAULT 0,
    PreferredContactMethod NVARCHAR(50),
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),
    FOREIGN KEY (IDVerifiedBy) REFERENCES Users(UserID),
    CHECK (ValidIDType IN ('Passport', 'DriverLicense', 'NationalID', 'Other')),
    INDEX IDX_RentalClient_Email (Email),
    INDEX IDX_RentalClient_Phone (Phone),
    INDEX IDX_RentalClient_IsIDVerified (IsIDVerified),
    INDEX IDX_RentalClient_IsBlacklisted (IsBlacklisted)
);

CREATE TABLE RentalAgreement (
    RentalAgreementID INT PRIMARY KEY IDENTITY(1,1),
    RentalClientID INT NOT NULL,
    EquipmentID INT NOT NULL,
    RentalStartDate DATETIME NOT NULL,
    RentalEndDate DATETIME NOT NULL,
    RentalDays INT,
    RentalRate DECIMAL(10,2),
    RentalCost DECIMAL(10,2),
    SecurityDeposit DECIMAL(10,2),
    DepositHeldDate DATETIME,
    DepositReturnedDate DATETIME,
    InsuranceRequired BIT DEFAULT 1,
    InsuranceType NVARCHAR(100),
    InsuranceCost DECIMAL(10,2),
    MaxDamageDeductible DECIMAL(10,2),
    TermsAccepted BIT DEFAULT 0,
    TermsAcceptedDate DATETIME,
    SignatureUrl NVARCHAR(500),
    EquipmentConditionOnHandover NVARCHAR(500),
    EquipmentConditionOnReturn NVARCHAR(500),
    DamageFound NVARCHAR(MAX),
    DamageCost DECIMAL(10,2),
    Status NVARCHAR(50) DEFAULT 'Pending',
    PaymentStatus NVARCHAR(50) DEFAULT 'Pending',
    CreatedBy INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    ReturnedAt DATETIME,
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),
    FOREIGN KEY (RentalClientID) REFERENCES RentalClient(RentalClientID),
    FOREIGN KEY (EquipmentID) REFERENCES Equipment(EquipmentID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    CHECK (Status IN ('Pending', 'Active', 'Returned', 'Cancelled', 'Disputed')),
    CHECK (PaymentStatus IN ('Pending', 'Partial', 'Paid', 'Refunded')),
    INDEX IDX_RentalAgreement_RentalClient (RentalClientID),
    INDEX IDX_RentalAgreement_Equipment (EquipmentID),
    INDEX IDX_RentalAgreement_Status (Status),
    INDEX IDX_RentalAgreement_DateRange (RentalStartDate, RentalEndDate)
);

CREATE TABLE RentalAgreementDocument (
    DocumentID INT PRIMARY KEY IDENTITY(1,1),
    RentalAgreementID INT NOT NULL,
    DocumentType NVARCHAR(50),
    DocumentUrl NVARCHAR(500),
    UploadedBy INT NOT NULL,
    UploadedAt DATETIME DEFAULT GETUTCDATE(),
    FOREIGN KEY (RentalAgreementID) REFERENCES RentalAgreement(RentalAgreementID) ON DELETE CASCADE,
    FOREIGN KEY (UploadedBy) REFERENCES Users(UserID),
    CHECK (DocumentType IN ('Agreement', 'IDVerification', 'Insurance', 'Signature', 'InspectionReport')),
    INDEX IDX_RentalAgreementDocument_Agreement (RentalAgreementID)
);

CREATE TABLE RentalReturnInspection (
    InspectionID INT PRIMARY KEY IDENTITY(1,1),
    RentalAgreementID INT NOT NULL,
    InspectionDate DATETIME DEFAULT GETUTCDATE(),
    InspectedBy INT NOT NULL,
    OverallCondition NVARCHAR(100),
    HasDamage BIT DEFAULT 0,
    DamageDescription NVARCHAR(MAX),
    PhotoUrl NVARCHAR(500),
    EstimatedRepairCost DECIMAL(10,2),
    IsFunctional BIT DEFAULT 1,
    TestNotes NVARCHAR(MAX),
    ApprovedBy INT,
    ApprovedAt DATETIME,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    FOREIGN KEY (RentalAgreementID) REFERENCES RentalAgreement(RentalAgreementID) ON DELETE CASCADE,
    FOREIGN KEY (InspectedBy) REFERENCES Users(UserID),
    FOREIGN KEY (ApprovedBy) REFERENCES Users(UserID),
    INDEX IDX_RentalReturnInspection_Agreement (RentalAgreementID)
);

-- ============================================
-- PORTFOLIO SHOWCASE (Gallery Before/After Links)
-- ============================================

CREATE TABLE PortfolioShowcase (
    ShowcaseID INT PRIMARY KEY IDENTITY(1,1),
    EventID INT,
    ServiceCategory NVARCHAR(100),
    BeforeGalleryID INT NOT NULL,
    AfterGalleryID INT NOT NULL,
    Description NVARCHAR(MAX),
    FeaturedRating INT,
    CreatedBy INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedBy INT,
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (EventID) REFERENCES Event(EventID),
    FOREIGN KEY (BeforeGalleryID) REFERENCES Gallery(GalleryID),
    FOREIGN KEY (AfterGalleryID) REFERENCES Gallery(GalleryID),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CHECK (FeaturedRating BETWEEN 1 AND 5 OR FeaturedRating IS NULL),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_PortfolioShowcase_EventID (EventID),
    INDEX IDX_PortfolioShowcase_ServiceCategory (ServiceCategory),
    INDEX IDX_PortfolioShowcase_FeaturedRating (FeaturedRating),
    INDEX IDX_PortfolioShowcase_CreatedBy (CreatedBy),
    INDEX IDX_PortfolioShowcase_IsDeleted (IsDeleted)
);

-- ============================================
-- EMAIL TEMPLATES
-- ============================================

CREATE TABLE EmailTemplate (
    TemplateID INT PRIMARY KEY IDENTITY(1,1),
    TemplateName NVARCHAR(255) NOT NULL UNIQUE,
    TemplateType NVARCHAR(50) NOT NULL,
    Subject NVARCHAR(500) NOT NULL,
    HtmlBody NVARCHAR(MAX) NOT NULL,
    PlaceholderVariables NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedBy INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedBy INT,
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CONSTRAINT CHK_EmailTemplate_TemplateType CHECK (TemplateType IN ('Invitation', 'Confirmation', 'Reminder', 'Notification', 'Receipt', 'Invoice', 'Other')),
    CONSTRAINT CHK_EmailTemplate_IsDeleted CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_EmailTemplate_TemplateType (TemplateType),
    INDEX IDX_EmailTemplate_IsActive (IsActive),
    INDEX IDX_EmailTemplate_CreatedBy (CreatedBy),
    INDEX IDX_EmailTemplate_IsDeleted (IsDeleted)
);

-- ============================================
-- CONTRACT TEMPLATES (Gap #18)
-- ============================================

CREATE TABLE ContractTemplate (
    ContractTemplateID INT PRIMARY KEY IDENTITY(1,1),
    ContractName NVARCHAR(255) NOT NULL UNIQUE,
    ServiceCategory NVARCHAR(100),
    TemplateText NVARCHAR(MAX) NOT NULL,
    PlaceholderVariables NVARCHAR(500),
    IsActive BIT DEFAULT 1,
    CreatedBy INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETUTCDATE(),
    UpdatedBy INT,
    UpdatedAt DATETIME DEFAULT GETUTCDATE(),
    DeletedBy INT,
    DeletedAt DATETIME,
    IsDeleted BIT DEFAULT 0,
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (UpdatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (DeletedBy) REFERENCES Users(UserID),
    CHECK (ServiceCategory IN ('Wedding', 'Portrait', 'Events', 'Video', 'Corporate', 'Other', NULL)),
    CHECK (IsDeleted IN (0, 1)),
    INDEX IDX_ContractTemplate_ServiceCategory (ServiceCategory),
    INDEX IDX_ContractTemplate_IsActive (IsActive),
    INDEX IDX_ContractTemplate_CreatedBy (CreatedBy),
    INDEX IDX_ContractTemplate_IsDeleted (IsDeleted)
);

-- ============================================
-- CREATE INDEXES
-- ============================================

CREATE INDEX IDX_Users_Email ON Users(Email);
CREATE INDEX IDX_Users_IsActive ON Users(IsActive);
CREATE INDEX IDX_UserRoles_UserID ON UserRoles(UserID);
CREATE INDEX IDX_UserRoles_RoleID ON UserRoles(RoleID);
CREATE INDEX IDX_Event_Status ON Event(Status);
CREATE INDEX IDX_Event_EventDate ON Event(EventDate);
CREATE INDEX IDX_Event_EventType ON Event(EventType);
CREATE INDEX IDX_Quotation_EventID ON Quotation(EventID);
CREATE INDEX IDX_Quotation_ClientEmail ON Quotation(ClientEmail);
CREATE INDEX IDX_Quotation_Status ON Quotation(Status);
CREATE INDEX IDX_QuotationItem_QuotationID ON QuotationItem(QuotationID);
CREATE INDEX IDX_Tag_TagType ON Tag(TagType);
CREATE INDEX IDX_Tag_TagName ON Tag(TagName);
CREATE INDEX IDX_EntityTag_EntityType ON EntityTag(EntityType);
CREATE INDEX IDX_EntityTag_TagID ON EntityTag(TagID);
CREATE INDEX IDX_Payment_InvoiceID ON Payment(InvoiceID);
CREATE INDEX IDX_Payment_BookingID ON Payment(BookingID);
CREATE INDEX IDX_Payment_Status ON Payment(Status);
CREATE INDEX IDX_Payment_PaymentMethodID ON Payment(PaymentMethodID);
CREATE INDEX IDX_BookingGallery_BookingID ON BookingGallery(BookingID);
CREATE INDEX IDX_BookingGallery_GalleryID ON BookingGallery(GalleryID);
CREATE INDEX IDX_Gallery_IsFeatured ON Gallery(IsFeatured);
CREATE INDEX IDX_Gallery_IsPublished ON Gallery(IsPublished);
CREATE INDEX IDX_Gallery_EventID ON Gallery(EventID);
CREATE INDEX IDX_Gallery_CreatedBy ON Gallery(CreatedBy);
CREATE INDEX IDX_Gallery_IsPrivate ON Gallery(IsPrivate);
CREATE INDEX IDX_Gallery_CreatedByIsPrivate ON Gallery(CreatedByUserID, IsPrivate);
CREATE INDEX IDX_GalleryAsset_GalleryID ON GalleryAsset(GalleryID);
CREATE INDEX IDX_GalleryAccess_GalleryID ON GalleryAccess(GalleryID);
CREATE INDEX IDX_GalleryAccess_UserID ON GalleryAccess(UserID);
CREATE INDEX IDX_Booking_ClientID ON Booking(ClientID);
CREATE INDEX IDX_Booking_PackageID ON Booking(PackageID);
CREATE INDEX IDX_Booking_QuotationID ON Booking(QuotationID);
CREATE INDEX IDX_Booking_PhotographerUserID ON Booking(PhotographerUserID);
CREATE INDEX IDX_Booking_Status ON Booking(Status);
CREATE INDEX IDX_Booking_BookingDate ON Booking(BookingDate);
CREATE INDEX IDX_Booking_IsDeleted ON Booking(IsDeleted);
CREATE INDEX IDX_CalendarBlock_BlockStart ON CalendarBlock(BlockStart);
CREATE INDEX IDX_CalendarBlock_BlockEnd ON CalendarBlock(BlockEnd);
CREATE INDEX IDX_CalendarBlock_BookingID ON CalendarBlock(BookingID);
CREATE INDEX IDX_Invoice_QuotationID ON Invoice(QuotationID);
CREATE INDEX IDX_Invoice_BookingID ON Invoice(BookingID);
CREATE INDEX IDX_Invoice_Status ON Invoice(Status);
CREATE INDEX IDX_DailyTask_Status ON DailyTask(Status);
CREATE INDEX IDX_ClientInfo_Email ON ClientInfo(Email);
CREATE INDEX IDX_ClientInfo_IsDeleted ON ClientInfo(IsDeleted);
CREATE INDEX IDX_ClientInfo_CreatedBy ON ClientInfo(CreatedBy);
CREATE INDEX IDX_ClientInfo_DeletedBy ON ClientInfo(DeletedBy);
CREATE INDEX IDX_PhotographyPackage_IsActive ON PhotographyPackage(IsActive);
CREATE INDEX IDX_PhotographyPackage_ServiceCategory ON PhotographyPackage(ServiceCategory);
CREATE INDEX IDX_Gallery_ReviewStatus ON Gallery(ReviewStatus);
CREATE INDEX IDX_GalleryAsset_AssetStatus ON GalleryAsset(AssetStatus);
CREATE INDEX IDX_BookingPackage_CampaignID ON BookingPackage(CampaignID);

-- ============================================
-- SOFT-DELETE INDEXES (IsDeleted Column Optimization)
-- ============================================

CREATE INDEX IDX_Event_IsDeleted ON Event(IsDeleted);
CREATE INDEX IDX_Gallery_IsDeleted ON Gallery(IsDeleted);
CREATE INDEX IDX_GalleryAsset_IsDeleted ON GalleryAsset(IsDeleted);
CREATE INDEX IDX_GalleryAccess_IsDeleted ON GalleryAccess(IsDeleted);
CREATE INDEX IDX_PhotographyPackage_IsDeleted ON PhotographyPackage(IsDeleted);
CREATE INDEX IDX_PackageComponent_IsDeleted ON PackageComponent(IsDeleted);
CREATE INDEX IDX_PackageAddOn_IsDeleted ON PackageAddOn(IsDeleted);
CREATE INDEX IDX_PackageDiscount_IsDeleted ON PackageDiscount(IsDeleted);
CREATE INDEX IDX_Campaign_IsDeleted ON Campaign(IsDeleted);
CREATE INDEX IDX_CampaignPackage_IsDeleted ON CampaignPackage(IsDeleted);
CREATE INDEX IDX_BookingPackage_IsDeleted ON BookingPackage(IsDeleted);
CREATE INDEX IDX_CalendarBlock_IsDeleted ON CalendarBlock(IsDeleted);
CREATE INDEX IDX_Availability_IsDeleted ON Availability(IsDeleted);
CREATE INDEX IDX_DailyTask_IsDeleted ON DailyTask(IsDeleted);
CREATE INDEX IDX_TaskComment_IsDeleted ON TaskComment(IsDeleted);
CREATE INDEX IDX_BookingLog_IsDeleted ON BookingLog(IsDeleted);
CREATE INDEX IDX_Invoice_IsDeleted ON Invoice(IsDeleted);
CREATE INDEX IDX_SEOMetadata_IsDeleted ON SEOMetadata(IsDeleted);
CREATE INDEX IDX_PortfolioShowcase_IsDeleted ON PortfolioShowcase(IsDeleted);
CREATE INDEX IDX_EmailTemplate_IsDeleted ON EmailTemplate(IsDeleted);
CREATE INDEX IDX_ContractTemplate_IsDeleted ON ContractTemplate(IsDeleted);

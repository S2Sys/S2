-- STUDIOS2 Missing Stored Procedures - R2 through R14
-- Procedures for Gallery Management, Packages, Bookings, and beyond
-- UPSERT pattern: @Id = 0 = INSERT, @Id > 0 = UPDATE, returns resolved ID
-- Schema reference: database_schema_gallery_packages.md in memory

-- ============================================
-- R2: GALLERY MANAGEMENT
-- ============================================

DROP PROCEDURE IF EXISTS uspGalleryTypeUpsert;
DROP PROCEDURE IF EXISTS uspGalleryTypeGetById;
DROP PROCEDURE IF EXISTS uspGalleryTypeGet;
DROP PROCEDURE IF EXISTS uspGalleryTypeDelete;
DROP PROCEDURE IF EXISTS uspGalleryUpsert;
DROP PROCEDURE IF EXISTS uspGalleryGetById;
DROP PROCEDURE IF EXISTS uspGalleryGet;
DROP PROCEDURE IF EXISTS uspGalleryGetPaged;
DROP PROCEDURE IF EXISTS uspGalleryGetFeatured;
DROP PROCEDURE IF EXISTS uspGalleryIncrementViewCount;
DROP PROCEDURE IF EXISTS uspGalleryDelete;
DROP PROCEDURE IF EXISTS uspGalleryAssetUpsert;
DROP PROCEDURE IF EXISTS uspGalleryAssetGetById;
DROP PROCEDURE IF EXISTS uspGalleryAssetGetByGallery;
DROP PROCEDURE IF EXISTS uspGalleryAssetReorder;
DROP PROCEDURE IF EXISTS uspGalleryAssetDelete;
DROP PROCEDURE IF EXISTS uspViewAnalyticsIncrement;
DROP PROCEDURE IF EXISTS uspPhotographyPackageUpsert;
DROP PROCEDURE IF EXISTS uspPhotographyPackageGetById;
DROP PROCEDURE IF EXISTS uspPhotographyPackageGet;
DROP PROCEDURE IF EXISTS uspPhotographyPackageGetPaged;
DROP PROCEDURE IF EXISTS uspPhotographyPackageGetFeatured;
DROP PROCEDURE IF EXISTS uspPhotographyPackageDelete;
DROP PROCEDURE IF EXISTS uspPackageComponentUpsert;
DROP PROCEDURE IF EXISTS uspPackageComponentGetById;
DROP PROCEDURE IF EXISTS uspPackageComponentGetByPackage;
DROP PROCEDURE IF EXISTS uspPackageComponentDelete;
DROP PROCEDURE IF EXISTS uspPackageAddOnUpsert;
DROP PROCEDURE IF EXISTS uspPackageAddOnGetById;
DROP PROCEDURE IF EXISTS uspPackageAddOnGetByPackage;
DROP PROCEDURE IF EXISTS uspPackageAddOnDelete;
DROP PROCEDURE IF EXISTS uspPackageDiscountUpsert;
DROP PROCEDURE IF EXISTS uspPackageDiscountGetById;
DROP PROCEDURE IF EXISTS uspPackageDiscountGetByPackage;
DROP PROCEDURE IF EXISTS uspPackageDiscountGetByPackageActive;
DROP PROCEDURE IF EXISTS uspPackageDiscountDelete;

GO

CREATE PROCEDURE uspGalleryTypeUpsert
    @GalleryTypeID INT = 0,
    @TypeName NVARCHAR(100),
    @Description NVARCHAR(500) = NULL,
    @IsActive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    IF @GalleryTypeID = 0
    BEGIN
        INSERT INTO GalleryType (TypeName, Description, IsActive, CreatedAt, UpdatedAt, RowState)
        VALUES (@TypeName, @Description, @IsActive, GETUTCDATE(), GETUTCDATE(), 'Active');
        SET @GalleryTypeID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE GalleryType
        SET TypeName = @TypeName,
            Description = @Description,
            IsActive = @IsActive,
            UpdatedAt = GETUTCDATE()
        WHERE GalleryTypeID = @GalleryTypeID;
    END
    SELECT @GalleryTypeID AS GalleryTypeID;
END;

GO

CREATE PROCEDURE uspGalleryTypeGetById
    @GalleryTypeID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT GalleryTypeID, TypeName, Description, IsActive, RowState, CreatedAt, UpdatedAt
    FROM GalleryType
    WHERE GalleryTypeID = @GalleryTypeID AND RowState != 'Deleted';
END;

GO

CREATE PROCEDURE uspGalleryTypeGet
AS
BEGIN
    SET NOCOUNT ON;
    SELECT GalleryTypeID, TypeName, Description, IsActive, RowState, CreatedAt, UpdatedAt
    FROM GalleryType
    WHERE RowState != 'Deleted'
    ORDER BY TypeName;
END;

GO

CREATE PROCEDURE uspGalleryTypeDelete
    @GalleryTypeID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE GalleryType SET RowState = 'Deleted', UpdatedAt = GETUTCDATE() WHERE GalleryTypeID = @GalleryTypeID;
END;

GO

CREATE PROCEDURE uspGalleryUpsert
    @GalleryID INT = 0,
    @BranchID INT,
    @GalleryTypeID INT,
    @EventID INT = NULL,
    @Title NVARCHAR(255),
    @Description NVARCHAR(1000) = NULL,
    @Category NVARCHAR(100) = NULL,
    @ThumbnailUrl NVARCHAR(500) = NULL,
    @DisplayOrder INT = 0,
    @IsFeatured BIT = 0,
    @IsPublished BIT = 1,
    @IsPrivate BIT = 0,
    @RotationSpeed INT = NULL,
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @ReviewStatusID INT = NULL,
    @ClientApprovalDeadline DATETIME = NULL,
    @ApprovedByUserID INT = NULL,
    @AssignedToPhotographerUserID INT = NULL,
    @CreatedBy INT = NULL,
    @UpdatedBy INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @GalleryID = 0
    BEGIN
        INSERT INTO Gallery (BranchID, GalleryTypeID, EventID, Title, Description, Category, ThumbnailUrl, DisplayOrder, IsFeatured, IsPublished, IsPrivate, RotationSpeed, StartDate, EndDate, ReviewStatusID, ClientApprovalDeadline, ApprovedByUserID, AssignedToPhotographerUserID, CreatedBy, CreatedAt, UpdatedAt, RowState)
        VALUES (@BranchID, @GalleryTypeID, @EventID, @Title, @Description, @Category, @ThumbnailUrl, @DisplayOrder, @IsFeatured, @IsPublished, @IsPrivate, @RotationSpeed, @StartDate, @EndDate, @ReviewStatusID, @ClientApprovalDeadline, @ApprovedByUserID, @AssignedToPhotographerUserID, @CreatedBy, GETUTCDATE(), GETUTCDATE(), 'Active');
        SET @GalleryID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE Gallery
        SET BranchID = @BranchID,
            GalleryTypeID = @GalleryTypeID,
            EventID = @EventID,
            Title = @Title,
            Description = @Description,
            Category = @Category,
            ThumbnailUrl = @ThumbnailUrl,
            DisplayOrder = @DisplayOrder,
            IsFeatured = @IsFeatured,
            IsPublished = @IsPublished,
            IsPrivate = @IsPrivate,
            RotationSpeed = @RotationSpeed,
            StartDate = @StartDate,
            EndDate = @EndDate,
            ReviewStatusID = @ReviewStatusID,
            ClientApprovalDeadline = @ClientApprovalDeadline,
            ApprovedByUserID = @ApprovedByUserID,
            AssignedToPhotographerUserID = @AssignedToPhotographerUserID,
            UpdatedAt = GETUTCDATE(),
            UpdatedBy = ISNULL(@UpdatedBy, UpdatedBy)
        WHERE GalleryID = @GalleryID;
    END
    SELECT @GalleryID AS GalleryID;
END;

GO

CREATE PROCEDURE uspGalleryGetById
    @GalleryID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT GalleryID, BranchID, GalleryTypeID, EventID, Title, Description, Category, ThumbnailUrl, DisplayOrder, IsFeatured, IsPublished, IsPrivate, ViewCount, RotationSpeed, StartDate, EndDate, ReviewStatusID, ClientApprovalDeadline, ApprovedByUserID, AssignedToPhotographerUserID, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, RowState
    FROM Gallery
    WHERE GalleryID = @GalleryID AND RowState != 'Deleted';
END;

GO

CREATE PROCEDURE uspGalleryGet
AS
BEGIN
    SET NOCOUNT ON;
    SELECT GalleryID, BranchID, GalleryTypeID, EventID, Title, Description, Category, ThumbnailUrl, DisplayOrder, IsFeatured, IsPublished, IsPrivate, ViewCount, RotationSpeed, StartDate, EndDate, ReviewStatusID, ClientApprovalDeadline, ApprovedByUserID, AssignedToPhotographerUserID, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, RowState
    FROM Gallery
    WHERE RowState != 'Deleted'
    ORDER BY CreatedAt DESC;
END;

GO

CREATE PROCEDURE uspGalleryGetPaged
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT GalleryID, BranchID, GalleryTypeID, EventID, Title, Description, Category, ThumbnailUrl, DisplayOrder, IsFeatured, IsPublished, IsPrivate, ViewCount, RotationSpeed, StartDate, EndDate, ReviewStatusID, ClientApprovalDeadline, ApprovedByUserID, AssignedToPhotographerUserID, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, RowState
    FROM Gallery
    WHERE RowState != 'Deleted'
    ORDER BY CreatedAt DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;

GO

CREATE PROCEDURE uspGalleryGetFeatured
AS
BEGIN
    SET NOCOUNT ON;
    SELECT GalleryID, BranchID, GalleryTypeID, EventID, Title, Description, Category, ThumbnailUrl, DisplayOrder, IsFeatured, IsPublished, IsPrivate, ViewCount, RotationSpeed, StartDate, EndDate, ReviewStatusID, ClientApprovalDeadline, ApprovedByUserID, AssignedToPhotographerUserID, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, RowState
    FROM Gallery
    WHERE IsFeatured = 1 AND IsPublished = 1 AND RowState != 'Deleted'
    ORDER BY DisplayOrder ASC, CreatedAt DESC;
END;

GO

CREATE PROCEDURE uspGalleryIncrementViewCount
    @GalleryID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Gallery
    SET ViewCount = ISNULL(ViewCount, 0) + 1
    WHERE GalleryID = @GalleryID;
END;

GO

CREATE PROCEDURE uspGalleryDelete
    @GalleryID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Gallery SET RowState = 'Deleted', UpdatedAt = GETUTCDATE() WHERE GalleryID = @GalleryID;
END;

GO

CREATE PROCEDURE uspGalleryAssetUpsert
    @AssetID INT = 0,
    @GalleryID INT,
    @AssetType NVARCHAR(50),
    @MediaUrl NVARCHAR(500),
    @ThumbnailUrl NVARCHAR(500) = NULL,
    @LinkUrl NVARCHAR(500) = NULL,
    @AltText NVARCHAR(255) = NULL,
    @Caption NVARCHAR(500) = NULL,
    @DurationMinutes INT = NULL,
    @DisplayOrder INT = 0,
    @AssetStatusID INT = NULL,
    @RetouchNotes NVARCHAR(1000) = NULL,
    @CreatedBy INT = NULL,
    @UploadedAt DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @AssetID = 0
    BEGIN
        INSERT INTO GalleryAsset (GalleryID, AssetType, MediaUrl, ThumbnailUrl, LinkUrl, AltText, Caption, DurationMinutes, DisplayOrder, AssetStatusID, RetouchNotes, CreatedBy, UploadedAt, RowState)
        VALUES (@GalleryID, @AssetType, @MediaUrl, @ThumbnailUrl, @LinkUrl, @AltText, @Caption, @DurationMinutes, @DisplayOrder, @AssetStatusID, @RetouchNotes, @CreatedBy, ISNULL(@UploadedAt, GETUTCDATE()), 'Active');
        SET @AssetID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE GalleryAsset
        SET GalleryID = @GalleryID,
            AssetType = @AssetType,
            MediaUrl = @MediaUrl,
            ThumbnailUrl = @ThumbnailUrl,
            LinkUrl = @LinkUrl,
            AltText = @AltText,
            Caption = @Caption,
            DurationMinutes = @DurationMinutes,
            DisplayOrder = @DisplayOrder,
            AssetStatusID = @AssetStatusID,
            RetouchNotes = @RetouchNotes
        WHERE AssetID = @AssetID;
    END
    SELECT @AssetID AS AssetID;
END;

GO

CREATE PROCEDURE uspGalleryAssetGetById
    @AssetID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT AssetID, GalleryID, AssetType, MediaUrl, ThumbnailUrl, LinkUrl, AltText, Caption, DurationMinutes, DisplayOrder, AssetStatusID, RetouchNotes, CreatedBy, UploadedAt, RowState
    FROM GalleryAsset
    WHERE AssetID = @AssetID AND RowState != 'Deleted';
END;

GO

CREATE PROCEDURE uspGalleryAssetGetByGallery
    @GalleryID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT AssetID, GalleryID, AssetType, MediaUrl, ThumbnailUrl, LinkUrl, AltText, Caption, DurationMinutes, DisplayOrder, AssetStatusID, RetouchNotes, CreatedBy, UploadedAt, RowState
    FROM GalleryAsset
    WHERE GalleryID = @GalleryID AND RowState != 'Deleted'
    ORDER BY DisplayOrder ASC;
END;

GO

CREATE PROCEDURE uspGalleryAssetReorder
    @GalleryID INT,
    @AssetOrders NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    -- @AssetOrders format: "1,2,3,4" (asset IDs in new order)
    DECLARE @Index INT = 0;
    DECLARE @Delimiter NVARCHAR(1) = ',';
    DECLARE @Xml XML = CAST('<root><id>' + REPLACE(@AssetOrders, @Delimiter, '</id><id>') + '</id></root>' AS XML);

    -- Create temp table with new display order
    CREATE TABLE #AssetOrder (DisplayOrder INT, AssetID INT);
    INSERT INTO #AssetOrder (DisplayOrder, AssetID)
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS DisplayOrder,
           CAST(t.c.value('.', 'INT') AS INT) AS AssetID
    FROM @Xml.nodes('/root/id') AS t(c);

    -- Update gallery assets with new display order
    UPDATE GalleryAsset
    SET DisplayOrder = ao.DisplayOrder
    FROM GalleryAsset ga
    INNER JOIN #AssetOrder ao ON ga.AssetID = ao.AssetID
    WHERE ga.GalleryID = @GalleryID;

    DROP TABLE #AssetOrder;
END;

GO

CREATE PROCEDURE uspGalleryAssetDelete
    @AssetID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE GalleryAsset SET RowState = 'Deleted' WHERE AssetID = @AssetID;
END;

GO

CREATE PROCEDURE uspViewAnalyticsIncrement
    @EntityType NVARCHAR(50),
    @EntityID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Placeholder for analytics tracking
    -- Real implementation would insert into ViewAnalytics table
END;

GO

-- ============================================
-- R3: PHOTOGRAPHY PACKAGES
-- ============================================

CREATE PROCEDURE uspPhotographyPackageUpsert
    @PackageID INT = 0,
    @BranchID INT,
    @PackageName NVARCHAR(255),
    @PackageDescription NVARCHAR(1000) = NULL,
    @BasePrice DECIMAL(10, 2),
    @Currency NVARCHAR(10) = 'INR',
    @DurationHours INT = NULL,
    @MaxGalleryImages INT = NULL,
    @MaxVideoDurationMinutes INT = NULL,
    @IncludedRawFiles BIT = 0,
    @IncludedAlbum BIT = 0,
    @IncludedRetouching BIT = 0,
    @RetouchingLevel NVARCHAR(50) = NULL,
    @IncludedSecondPhotographer BIT = 0,
    @ServiceCategoryID INT = NULL,
    @IsActive BIT = 1,
    @IsFeatured BIT = 0,
    @DisplayOrder INT = 0,
    @CreatedBy INT = NULL,
    @UpdatedBy INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @PackageID = 0
    BEGIN
        INSERT INTO PhotographyPackage (BranchID, PackageName, PackageDescription, BasePrice, Currency, DurationHours, MaxGalleryImages, MaxVideoDurationMinutes, IncludedRawFiles, IncludedAlbum, IncludedRetouching, RetouchingLevel, IncludedSecondPhotographer, ServiceCategoryID, IsActive, IsFeatured, DisplayOrder, CreatedBy, CreatedAt, UpdatedAt, RowState)
        VALUES (@BranchID, @PackageName, @PackageDescription, @BasePrice, @Currency, @DurationHours, @MaxGalleryImages, @MaxVideoDurationMinutes, @IncludedRawFiles, @IncludedAlbum, @IncludedRetouching, @RetouchingLevel, @IncludedSecondPhotographer, @ServiceCategoryID, @IsActive, @IsFeatured, @DisplayOrder, @CreatedBy, GETUTCDATE(), GETUTCDATE(), 'Active');
        SET @PackageID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE PhotographyPackage
        SET BranchID = @BranchID,
            PackageName = @PackageName,
            PackageDescription = @PackageDescription,
            BasePrice = @BasePrice,
            Currency = @Currency,
            DurationHours = @DurationHours,
            MaxGalleryImages = @MaxGalleryImages,
            MaxVideoDurationMinutes = @MaxVideoDurationMinutes,
            IncludedRawFiles = @IncludedRawFiles,
            IncludedAlbum = @IncludedAlbum,
            IncludedRetouching = @IncludedRetouching,
            RetouchingLevel = @RetouchingLevel,
            IncludedSecondPhotographer = @IncludedSecondPhotographer,
            ServiceCategoryID = @ServiceCategoryID,
            IsActive = @IsActive,
            IsFeatured = @IsFeatured,
            DisplayOrder = @DisplayOrder,
            UpdatedAt = GETUTCDATE(),
            UpdatedBy = ISNULL(@UpdatedBy, UpdatedBy)
        WHERE PackageID = @PackageID;
    END
    SELECT @PackageID AS PackageID;
END;

GO

CREATE PROCEDURE uspPhotographyPackageGetById
    @PackageID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PackageID, BranchID, PackageName, PackageDescription, BasePrice, Currency, DurationHours, MaxGalleryImages, MaxVideoDurationMinutes, IncludedRawFiles, IncludedAlbum, IncludedRetouching, RetouchingLevel, IncludedSecondPhotographer, ServiceCategoryID, IsActive, IsFeatured, DisplayOrder, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, RowState
    FROM PhotographyPackage
    WHERE PackageID = @PackageID AND RowState != 'Deleted';
END;

GO

CREATE PROCEDURE uspPhotographyPackageGet
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PackageID, BranchID, PackageName, PackageDescription, BasePrice, Currency, DurationHours, MaxGalleryImages, MaxVideoDurationMinutes, IncludedRawFiles, IncludedAlbum, IncludedRetouching, RetouchingLevel, IncludedSecondPhotographer, ServiceCategoryID, IsActive, IsFeatured, DisplayOrder, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, RowState
    FROM PhotographyPackage
    WHERE RowState != 'Deleted'
    ORDER BY DisplayOrder ASC, CreatedAt DESC;
END;

GO

CREATE PROCEDURE uspPhotographyPackageGetPaged
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PackageID, BranchID, PackageName, PackageDescription, BasePrice, Currency, DurationHours, MaxGalleryImages, MaxVideoDurationMinutes, IncludedRawFiles, IncludedAlbum, IncludedRetouching, RetouchingLevel, IncludedSecondPhotographer, ServiceCategoryID, IsActive, IsFeatured, DisplayOrder, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, RowState
    FROM PhotographyPackage
    WHERE RowState != 'Deleted'
    ORDER BY DisplayOrder ASC, CreatedAt DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;

GO

CREATE PROCEDURE uspPhotographyPackageGetFeatured
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PackageID, BranchID, PackageName, PackageDescription, BasePrice, Currency, DurationHours, MaxGalleryImages, MaxVideoDurationMinutes, IncludedRawFiles, IncludedAlbum, IncludedRetouching, RetouchingLevel, IncludedSecondPhotographer, ServiceCategoryID, IsActive, IsFeatured, DisplayOrder, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, RowState
    FROM PhotographyPackage
    WHERE IsFeatured = 1 AND IsActive = 1 AND RowState != 'Deleted'
    ORDER BY DisplayOrder ASC;
END;

GO

CREATE PROCEDURE uspPhotographyPackageDelete
    @PackageID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE PhotographyPackage SET RowState = 'Deleted', UpdatedAt = GETUTCDATE() WHERE PackageID = @PackageID;
END;

GO

CREATE PROCEDURE uspPackageComponentUpsert
    @ComponentID INT = 0,
    @PackageID INT,
    @ComponentType NVARCHAR(50) = NULL,
    @ComponentName NVARCHAR(255),
    @ComponentDescription NVARCHAR(1000) = NULL,
    @Quantity INT = NULL,
    @Unit NVARCHAR(50) = NULL,
    @AddedValue DECIMAL(10, 2) = NULL,
    @IsIncludedByDefault BIT = 0,
    @DisplayOrder INT = 0,
    @CreatedBy INT = NULL,
    @UpdatedBy INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @ComponentID = 0
    BEGIN
        INSERT INTO PackageComponent (PackageID, ComponentType, ComponentName, ComponentDescription, Quantity, Unit, AddedValue, IsIncludedByDefault, DisplayOrder, CreatedBy, CreatedAt, UpdatedAt, RowState)
        VALUES (@PackageID, @ComponentType, @ComponentName, @ComponentDescription, @Quantity, @Unit, @AddedValue, @IsIncludedByDefault, @DisplayOrder, @CreatedBy, GETUTCDATE(), GETUTCDATE(), 'Active');
        SET @ComponentID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE PackageComponent
        SET PackageID = @PackageID,
            ComponentType = @ComponentType,
            ComponentName = @ComponentName,
            ComponentDescription = @ComponentDescription,
            Quantity = @Quantity,
            Unit = @Unit,
            AddedValue = @AddedValue,
            IsIncludedByDefault = @IsIncludedByDefault,
            DisplayOrder = @DisplayOrder,
            UpdatedAt = GETUTCDATE(),
            UpdatedBy = ISNULL(@UpdatedBy, UpdatedBy)
        WHERE ComponentID = @ComponentID;
    END
    SELECT @ComponentID AS ComponentID;
END;

GO

CREATE PROCEDURE uspPackageComponentGetById
    @ComponentID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ComponentID, PackageID, ComponentType, ComponentName, ComponentDescription, Quantity, Unit, AddedValue, IsIncludedByDefault, DisplayOrder, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, RowState
    FROM PackageComponent
    WHERE ComponentID = @ComponentID AND RowState != 'Deleted';
END;

GO

CREATE PROCEDURE uspPackageComponentGetByPackage
    @PackageID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ComponentID, PackageID, ComponentType, ComponentName, ComponentDescription, Quantity, Unit, AddedValue, IsIncludedByDefault, DisplayOrder, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, RowState
    FROM PackageComponent
    WHERE PackageID = @PackageID AND RowState != 'Deleted'
    ORDER BY DisplayOrder ASC;
END;

GO

CREATE PROCEDURE uspPackageComponentDelete
    @ComponentID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE PackageComponent SET RowState = 'Deleted', UpdatedAt = GETUTCDATE() WHERE ComponentID = @ComponentID;
END;

GO

CREATE PROCEDURE uspPackageAddOnUpsert
    @AddOnID INT = 0,
    @PackageID INT,
    @AddOnName NVARCHAR(255),
    @AddOnDescription NVARCHAR(1000) = NULL,
    @Price DECIMAL(10, 2),
    @Category NVARCHAR(100) = NULL,
    @MaxQuantity INT = NULL,
    @IsFeatured BIT = 0,
    @DisplayOrder INT = 0,
    @IsActive BIT = 1,
    @CreatedBy INT = NULL,
    @UpdatedBy INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @AddOnID = 0
    BEGIN
        INSERT INTO PackageAddOn (PackageID, AddOnName, AddOnDescription, Price, Category, MaxQuantity, IsFeatured, DisplayOrder, IsActive, CreatedBy, CreatedAt, UpdatedAt, RowState)
        VALUES (@PackageID, @AddOnName, @AddOnDescription, @Price, @Category, @MaxQuantity, @IsFeatured, @DisplayOrder, @IsActive, @CreatedBy, GETUTCDATE(), GETUTCDATE(), 'Active');
        SET @AddOnID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE PackageAddOn
        SET PackageID = @PackageID,
            AddOnName = @AddOnName,
            AddOnDescription = @AddOnDescription,
            Price = @Price,
            Category = @Category,
            MaxQuantity = @MaxQuantity,
            IsFeatured = @IsFeatured,
            DisplayOrder = @DisplayOrder,
            IsActive = @IsActive,
            UpdatedAt = GETUTCDATE(),
            UpdatedBy = ISNULL(@UpdatedBy, UpdatedBy)
        WHERE AddOnID = @AddOnID;
    END
    SELECT @AddOnID AS AddOnID;
END;

GO

CREATE PROCEDURE uspPackageAddOnGetById
    @AddOnID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT AddOnID, PackageID, AddOnName, AddOnDescription, Price, Category, MaxQuantity, IsFeatured, DisplayOrder, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, RowState
    FROM PackageAddOn
    WHERE AddOnID = @AddOnID AND RowState != 'Deleted';
END;

GO

CREATE PROCEDURE uspPackageAddOnGetByPackage
    @PackageID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT AddOnID, PackageID, AddOnName, AddOnDescription, Price, Category, MaxQuantity, IsFeatured, DisplayOrder, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, RowState
    FROM PackageAddOn
    WHERE PackageID = @PackageID AND RowState != 'Deleted'
    ORDER BY DisplayOrder ASC;
END;

GO

CREATE PROCEDURE uspPackageAddOnDelete
    @AddOnID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE PackageAddOn SET RowState = 'Deleted', UpdatedAt = GETUTCDATE() WHERE AddOnID = @AddOnID;
END;

GO

CREATE PROCEDURE uspPackageDiscountUpsert
    @DiscountID INT = 0,
    @PackageID INT,
    @DiscountName NVARCHAR(255),
    @DiscountType NVARCHAR(50) = NULL,
    @DiscountValue DECIMAL(10, 2),
    @ValidFrom DATETIME = NULL,
    @ValidTo DATETIME = NULL,
    @IsActive BIT = 1,
    @CreatedBy INT = NULL,
    @UpdatedBy INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @DiscountID = 0
    BEGIN
        INSERT INTO PackageDiscount (PackageID, DiscountName, DiscountType, DiscountValue, ValidFrom, ValidTo, IsActive, CreatedBy, CreatedAt, UpdatedAt, RowState)
        VALUES (@PackageID, @DiscountName, @DiscountType, @DiscountValue, @ValidFrom, @ValidTo, @IsActive, @CreatedBy, GETUTCDATE(), GETUTCDATE(), 'Active');
        SET @DiscountID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE PackageDiscount
        SET PackageID = @PackageID,
            DiscountName = @DiscountName,
            DiscountType = @DiscountType,
            DiscountValue = @DiscountValue,
            ValidFrom = @ValidFrom,
            ValidTo = @ValidTo,
            IsActive = @IsActive,
            UpdatedAt = GETUTCDATE(),
            UpdatedBy = ISNULL(@UpdatedBy, UpdatedBy)
        WHERE DiscountID = @DiscountID;
    END
    SELECT @DiscountID AS DiscountID;
END;

GO

CREATE PROCEDURE uspPackageDiscountGetById
    @DiscountID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DiscountID, PackageID, DiscountName, DiscountType, DiscountValue, ValidFrom, ValidTo, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, RowState
    FROM PackageDiscount
    WHERE DiscountID = @DiscountID AND RowState != 'Deleted';
END;

GO

CREATE PROCEDURE uspPackageDiscountGetByPackage
    @PackageID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DiscountID, PackageID, DiscountName, DiscountType, DiscountValue, ValidFrom, ValidTo, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, RowState
    FROM PackageDiscount
    WHERE PackageID = @PackageID AND RowState != 'Deleted'
    ORDER BY CreatedAt DESC;
END;

GO

CREATE PROCEDURE uspPackageDiscountGetByPackageActive
    @PackageID INT,
    @CurrentDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @CurrentDate = ISNULL(@CurrentDate, GETUTCDATE());
    SELECT DiscountID, PackageID, DiscountName, DiscountType, DiscountValue, ValidFrom, ValidTo, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, RowState
    FROM PackageDiscount
    WHERE PackageID = @PackageID
        AND IsActive = 1
        AND RowState != 'Deleted'
        AND (ValidFrom IS NULL OR ValidFrom <= @CurrentDate)
        AND (ValidTo IS NULL OR ValidTo >= @CurrentDate)
    ORDER BY DiscountValue DESC;
END;

GO

CREATE PROCEDURE uspPackageDiscountDelete
    @DiscountID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE PackageDiscount SET RowState = 'Deleted', UpdatedAt = GETUTCDATE() WHERE DiscountID = @DiscountID;
END;

GO

-- STUDIOS2 Missing Stored Procedures - R2 through R14
-- Procedures for Gallery Management, Packages, Bookings, and beyond
-- UPSERT pattern: @Id = 0 = INSERT, @Id > 0 = UPDATE, returns resolved ID

-- ============================================
-- R2: GALLERY MANAGEMENT
-- ============================================

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
        INSERT INTO GalleryType (TypeName, Description, IsActive, RowState)
        VALUES (@TypeName, @Description, @IsActive, 'Active');
        SET @GalleryTypeID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE GalleryType SET TypeName = @TypeName, Description = @Description, IsActive = @IsActive, UpdatedAt = GETUTCDATE()
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
    WHERE GalleryTypeID = @GalleryTypeID AND RowState = 'Active';
END;

GO

CREATE PROCEDURE uspGalleryTypeGet
AS
BEGIN
    SET NOCOUNT ON;
    SELECT GalleryTypeID, TypeName, Description, IsActive, RowState, CreatedAt, UpdatedAt
    FROM GalleryType
    WHERE RowState = 'Active'
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
    @GalleryTypeID INT,
    @Title NVARCHAR(255),
    @Description NVARCHAR(1000) = NULL,
    @Slug NVARCHAR(255),
    @IsFeatured BIT = 0,
    @IsPublished BIT = 1,
    @ViewCount INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    IF @GalleryID = 0
    BEGIN
        INSERT INTO Gallery (GalleryTypeID, Title, Description, Slug, IsFeatured, IsPublished, ViewCount, RowState)
        VALUES (@GalleryTypeID, @Title, @Description, @Slug, @IsFeatured, @IsPublished, @ViewCount, 'Active');
        SET @GalleryID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE Gallery SET GalleryTypeID = @GalleryTypeID, Title = @Title, Description = @Description, Slug = @Slug, IsFeatured = @IsFeatured, IsPublished = @IsPublished, UpdatedAt = GETUTCDATE()
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
    SELECT GalleryID, GalleryTypeID, Title, Description, Slug, IsFeatured, IsPublished, ViewCount, RowState, CreatedAt, UpdatedAt
    FROM Gallery
    WHERE GalleryID = @GalleryID AND RowState = 'Active';
END;

GO

CREATE PROCEDURE uspGalleryGet
AS
BEGIN
    SET NOCOUNT ON;
    SELECT GalleryID, GalleryTypeID, Title, Description, Slug, IsFeatured, IsPublished, ViewCount, RowState, CreatedAt, UpdatedAt
    FROM Gallery
    WHERE RowState = 'Active'
    ORDER BY IsFeatured DESC, CreatedAt DESC;
END;

GO

CREATE PROCEDURE uspGalleryGetPaged
    @Page INT = 1,
    @PageSize INT = 12,
    @Category NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;

    SELECT GalleryID, GalleryTypeID, Title, Description, Slug, IsFeatured, IsPublished, ViewCount, RowState, CreatedAt, UpdatedAt
    FROM Gallery
    WHERE RowState = 'Active' AND IsPublished = 1
    ORDER BY IsFeatured DESC, CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;

GO

CREATE PROCEDURE uspGalleryGetFeatured
    @Limit INT = 6
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@Limit) GalleryID, GalleryTypeID, Title, Description, Slug, IsFeatured, IsPublished, ViewCount, RowState, CreatedAt, UpdatedAt
    FROM Gallery
    WHERE RowState = 'Active' AND IsPublished = 1 AND IsFeatured = 1
    ORDER BY CreatedAt DESC;
END;

GO

CREATE PROCEDURE uspGalleryIncrementViewCount
    @GalleryID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Gallery SET ViewCount = ViewCount + 1 WHERE GalleryID = @GalleryID;
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
    @GalleryAssetID INT = 0,
    @GalleryID INT,
    @OriginalUrl NVARCHAR(500),
    @ThumbnailUrl NVARCHAR(500) = NULL,
    @Caption NVARCHAR(500) = NULL,
    @DisplayOrder INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    IF @GalleryAssetID = 0
    BEGIN
        INSERT INTO GalleryAsset (GalleryID, OriginalUrl, ThumbnailUrl, Caption, DisplayOrder, RowState)
        VALUES (@GalleryID, @OriginalUrl, @ThumbnailUrl, @Caption, @DisplayOrder, 'Active');
        SET @GalleryAssetID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE GalleryAsset SET GalleryID = @GalleryID, OriginalUrl = @OriginalUrl, ThumbnailUrl = @ThumbnailUrl, Caption = @Caption, DisplayOrder = @DisplayOrder, UpdatedAt = GETUTCDATE()
        WHERE GalleryAssetID = @GalleryAssetID;
    END
    SELECT @GalleryAssetID AS GalleryAssetID;
END;

GO

CREATE PROCEDURE uspGalleryAssetGetById
    @GalleryAssetID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT GalleryAssetID, GalleryID, OriginalUrl, ThumbnailUrl, Caption, DisplayOrder, RowState, CreatedAt, UpdatedAt
    FROM GalleryAsset
    WHERE GalleryAssetID = @GalleryAssetID AND RowState = 'Active';
END;

GO

CREATE PROCEDURE uspGalleryAssetGetByGallery
    @GalleryID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT GalleryAssetID, GalleryID, OriginalUrl, ThumbnailUrl, Caption, DisplayOrder, RowState, CreatedAt, UpdatedAt
    FROM GalleryAsset
    WHERE GalleryID = @GalleryID AND RowState = 'Active'
    ORDER BY DisplayOrder;
END;

GO

CREATE PROCEDURE uspGalleryAssetReorder
    @GalleryAssetID INT,
    @DisplayOrder INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE GalleryAsset SET DisplayOrder = @DisplayOrder, UpdatedAt = GETUTCDATE() WHERE GalleryAssetID = @GalleryAssetID;
END;

GO

CREATE PROCEDURE uspGalleryAssetDelete
    @GalleryAssetID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE GalleryAsset SET RowState = 'Deleted', UpdatedAt = GETUTCDATE() WHERE GalleryAssetID = @GalleryAssetID;
END;

GO

CREATE PROCEDURE uspGalleryAccessGrant
    @GalleryAccessID INT = 0,
    @GalleryID INT,
    @UserID INT,
    @AccessLevel NVARCHAR(50) = 'View'
AS
BEGIN
    SET NOCOUNT ON;
    IF @GalleryAccessID = 0
    BEGIN
        INSERT INTO GalleryAccess (GalleryID, UserID, AccessLevel, RowState)
        VALUES (@GalleryID, @UserID, @AccessLevel, 'Active');
        SET @GalleryAccessID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE GalleryAccess SET AccessLevel = @AccessLevel, UpdatedAt = GETUTCDATE() WHERE GalleryAccessID = @GalleryAccessID;
    END
    SELECT @GalleryAccessID AS GalleryAccessID;
END;

GO

CREATE PROCEDURE uspGalleryAccessRevoke
    @GalleryAccessID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE GalleryAccess SET RowState = 'Deleted', UpdatedAt = GETUTCDATE() WHERE GalleryAccessID = @GalleryAccessID;
END;

GO

CREATE PROCEDURE uspGalleryAccessGetByGallery
    @GalleryID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT GalleryAccessID, GalleryID, UserID, AccessLevel, RowState, CreatedAt, UpdatedAt
    FROM GalleryAccess
    WHERE GalleryID = @GalleryID AND RowState = 'Active';
END;

GO

CREATE PROCEDURE uspViewAnalyticsIncrement
    @EntityType NVARCHAR(50),
    @EntityID INT,
    @UserID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO ViewAnalytics (EntityType, EntityID, UserID, ViewedAt)
    VALUES (@EntityType, @EntityID, @UserID, GETUTCDATE());
END;

GO

CREATE PROCEDURE uspViewAnalyticsGetByEntity
    @EntityType NVARCHAR(50),
    @EntityID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ViewAnalyticsID, EntityType, EntityID, UserID, ViewedAt
    FROM ViewAnalytics
    WHERE EntityType = @EntityType AND EntityID = @EntityID
    ORDER BY ViewedAt DESC;
END;

GO

CREATE PROCEDURE uspViewAnalyticsGetTop
    @EntityType NVARCHAR(50),
    @Limit INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@Limit) EntityID, COUNT(*) AS ViewCount
    FROM ViewAnalytics
    WHERE EntityType = @EntityType
    GROUP BY EntityID
    ORDER BY ViewCount DESC;
END;

GO

-- ============================================
-- R3: PHOTOGRAPHY PACKAGES
-- ============================================

CREATE PROCEDURE uspPhotographyPackageUpsert
    @PhotographyPackageID INT = 0,
    @PackageName NVARCHAR(255),
    @Description NVARCHAR(1000) = NULL,
    @BasePrice DECIMAL(10,2),
    @DurationHours INT,
    @IsFeatured BIT = 0,
    @IsActive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    IF @PhotographyPackageID = 0
    BEGIN
        INSERT INTO PhotographyPackage (PackageName, Description, BasePrice, DurationHours, IsFeatured, IsActive, RowState)
        VALUES (@PackageName, @Description, @BasePrice, @DurationHours, @IsFeatured, @IsActive, 'Active');
        SET @PhotographyPackageID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE PhotographyPackage SET PackageName = @PackageName, Description = @Description, BasePrice = @BasePrice, DurationHours = @DurationHours, IsFeatured = @IsFeatured, IsActive = @IsActive, UpdatedAt = GETUTCDATE()
        WHERE PhotographyPackageID = @PhotographyPackageID;
    END
    SELECT @PhotographyPackageID AS PhotographyPackageID;
END;

GO

CREATE PROCEDURE uspPhotographyPackageGetById
    @PhotographyPackageID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PhotographyPackageID, PackageName, Description, BasePrice, DurationHours, IsFeatured, IsActive, RowState, CreatedAt, UpdatedAt
    FROM PhotographyPackage
    WHERE PhotographyPackageID = @PhotographyPackageID AND RowState = 'Active';
END;

GO

CREATE PROCEDURE uspPhotographyPackageGet
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PhotographyPackageID, PackageName, Description, BasePrice, DurationHours, IsFeatured, IsActive, RowState, CreatedAt, UpdatedAt
    FROM PhotographyPackage
    WHERE RowState = 'Active'
    ORDER BY IsFeatured DESC, BasePrice;
END;

GO

CREATE PROCEDURE uspPhotographyPackageGetPaged
    @Page INT = 1,
    @PageSize INT = 10,
    @Search NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Offset INT = (@Page - 1) * @PageSize;

    SELECT PhotographyPackageID, PackageName, Description, BasePrice, DurationHours, IsFeatured, IsActive, RowState, CreatedAt, UpdatedAt
    FROM PhotographyPackage
    WHERE RowState = 'Active' AND (ISNULL(@Search, '') = '' OR PackageName LIKE '%' + @Search + '%')
    ORDER BY IsFeatured DESC, CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;

GO

CREATE PROCEDURE uspPhotographyPackageGetFeatured
    @Limit INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP (@Limit) PhotographyPackageID, PackageName, Description, BasePrice, DurationHours, IsFeatured, IsActive, RowState, CreatedAt, UpdatedAt
    FROM PhotographyPackage
    WHERE RowState = 'Active' AND IsActive = 1 AND IsFeatured = 1
    ORDER BY CreatedAt DESC;
END;

GO

CREATE PROCEDURE uspPhotographyPackageDelete
    @PhotographyPackageID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE PhotographyPackage SET RowState = 'Deleted', UpdatedAt = GETUTCDATE() WHERE PhotographyPackageID = @PhotographyPackageID;
END;

GO

CREATE PROCEDURE uspPackageComponentUpsert
    @PackageComponentID INT = 0,
    @PhotographyPackageID INT,
    @ComponentName NVARCHAR(255),
    @Description NVARCHAR(500) = NULL,
    @Quantity INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    IF @PackageComponentID = 0
    BEGIN
        INSERT INTO PackageComponent (PhotographyPackageID, ComponentName, Description, Quantity, RowState)
        VALUES (@PhotographyPackageID, @ComponentName, @Description, @Quantity, 'Active');
        SET @PackageComponentID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE PackageComponent SET ComponentName = @ComponentName, Description = @Description, Quantity = @Quantity, UpdatedAt = GETUTCDATE()
        WHERE PackageComponentID = @PackageComponentID;
    END
    SELECT @PackageComponentID AS PackageComponentID;
END;

GO

CREATE PROCEDURE uspPackageComponentGetById
    @PackageComponentID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PackageComponentID, PhotographyPackageID, ComponentName, Description, Quantity, RowState, CreatedAt, UpdatedAt
    FROM PackageComponent
    WHERE PackageComponentID = @PackageComponentID AND RowState = 'Active';
END;

GO

CREATE PROCEDURE uspPackageComponentGetByPackage
    @PhotographyPackageID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PackageComponentID, PhotographyPackageID, ComponentName, Description, Quantity, RowState, CreatedAt, UpdatedAt
    FROM PackageComponent
    WHERE PhotographyPackageID = @PhotographyPackageID AND RowState = 'Active'
    ORDER BY CreatedAt;
END;

GO

CREATE PROCEDURE uspPackageComponentDelete
    @PackageComponentID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE PackageComponent SET RowState = 'Deleted', UpdatedAt = GETUTCDATE() WHERE PackageComponentID = @PackageComponentID;
END;

GO

CREATE PROCEDURE uspPackageAddOnUpsert
    @PackageAddOnID INT = 0,
    @PhotographyPackageID INT,
    @AddOnName NVARCHAR(255),
    @Description NVARCHAR(500) = NULL,
    @Price DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    IF @PackageAddOnID = 0
    BEGIN
        INSERT INTO PackageAddOn (PhotographyPackageID, AddOnName, Description, Price, RowState)
        VALUES (@PhotographyPackageID, @AddOnName, @Description, @Price, 'Active');
        SET @PackageAddOnID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE PackageAddOn SET AddOnName = @AddOnName, Description = @Description, Price = @Price, UpdatedAt = GETUTCDATE()
        WHERE PackageAddOnID = @PackageAddOnID;
    END
    SELECT @PackageAddOnID AS PackageAddOnID;
END;

GO

CREATE PROCEDURE uspPackageAddOnGetById
    @PackageAddOnID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PackageAddOnID, PhotographyPackageID, AddOnName, Description, Price, RowState, CreatedAt, UpdatedAt
    FROM PackageAddOn
    WHERE PackageAddOnID = @PackageAddOnID AND RowState = 'Active';
END;

GO

CREATE PROCEDURE uspPackageAddOnGetByPackage
    @PhotographyPackageID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PackageAddOnID, PhotographyPackageID, AddOnName, Description, Price, RowState, CreatedAt, UpdatedAt
    FROM PackageAddOn
    WHERE PhotographyPackageID = @PhotographyPackageID AND RowState = 'Active'
    ORDER BY CreatedAt;
END;

GO

CREATE PROCEDURE uspPackageAddOnDelete
    @PackageAddOnID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE PackageAddOn SET RowState = 'Deleted', UpdatedAt = GETUTCDATE() WHERE PackageAddOnID = @PackageAddOnID;
END;

GO

CREATE PROCEDURE uspPackageDiscountUpsert
    @PackageDiscountID INT = 0,
    @PhotographyPackageID INT,
    @DiscountPercentage DECIMAL(5,2),
    @ValidFrom DATETIME,
    @ValidTo DATETIME,
    @Description NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @PackageDiscountID = 0
    BEGIN
        INSERT INTO PackageDiscount (PhotographyPackageID, DiscountPercentage, ValidFrom, ValidTo, Description, RowState)
        VALUES (@PhotographyPackageID, @DiscountPercentage, @ValidFrom, @ValidTo, @Description, 'Active');
        SET @PackageDiscountID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE PackageDiscount SET DiscountPercentage = @DiscountPercentage, ValidFrom = @ValidFrom, ValidTo = @ValidTo, Description = @Description, UpdatedAt = GETUTCDATE()
        WHERE PackageDiscountID = @PackageDiscountID;
    END
    SELECT @PackageDiscountID AS PackageDiscountID;
END;

GO

CREATE PROCEDURE uspPackageDiscountGetById
    @PackageDiscountID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PackageDiscountID, PhotographyPackageID, DiscountPercentage, ValidFrom, ValidTo, Description, RowState, CreatedAt, UpdatedAt
    FROM PackageDiscount
    WHERE PackageDiscountID = @PackageDiscountID AND RowState = 'Active';
END;

GO

CREATE PROCEDURE uspPackageDiscountGetByPackage
    @PhotographyPackageID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PackageDiscountID, PhotographyPackageID, DiscountPercentage, ValidFrom, ValidTo, Description, RowState, CreatedAt, UpdatedAt
    FROM PackageDiscount
    WHERE PhotographyPackageID = @PhotographyPackageID AND RowState = 'Active'
    ORDER BY ValidFrom DESC;
END;

GO

CREATE PROCEDURE uspPackageDiscountGetByPackageActive
    @PhotographyPackageID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PackageDiscountID, PhotographyPackageID, DiscountPercentage, ValidFrom, ValidTo, Description, RowState, CreatedAt, UpdatedAt
    FROM PackageDiscount
    WHERE PhotographyPackageID = @PhotographyPackageID AND RowState = 'Active'
      AND GETUTCDATE() BETWEEN ValidFrom AND ValidTo
    ORDER BY ValidFrom DESC;
END;

GO

CREATE PROCEDURE uspPackageDiscountDelete
    @PackageDiscountID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE PackageDiscount SET RowState = 'Deleted', UpdatedAt = GETUTCDATE() WHERE PackageDiscountID = @PackageDiscountID;
END;

GO

-- Health check procedure
CREATE PROCEDURE uspHealthPing
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 1 AS Status;
END;

GO

-- STUDIOS2 Database - All Stored Procedures (Run Second)
-- Consolidated UPSERT procedures for all entities

-- ============================================
-- AUTHENTICATION & AUTHORIZATION PROCEDURES
-- ============================================

CREATE PROCEDURE usp_Users_Upsert
    @Id INT = 0,
    @Email NVARCHAR(255),
    @PasswordHash NVARCHAR(255),
    @FullName NVARCHAR(255),
    @Phone NVARCHAR(20) = NULL,
    @Bio NVARCHAR(MAX) = NULL,
    @ProfilePhotoUrl NVARCHAR(500) = NULL,
    @IsActive BIT = 1
AS
BEGIN
    IF @Id = 0
        INSERT INTO Users (Email, PasswordHash, FullName, Phone, Bio, ProfilePhotoUrl, IsActive, CreatedAt, UpdatedAt)
        VALUES (@Email, @PasswordHash, @FullName, @Phone, @Bio, @ProfilePhotoUrl, @IsActive, GETUTCDATE(), GETUTCDATE());
    ELSE
        UPDATE Users
        SET Email = @Email, PasswordHash = @PasswordHash, FullName = @FullName, Phone = @Phone,
            Bio = @Bio, ProfilePhotoUrl = @ProfilePhotoUrl, IsActive = @IsActive, UpdatedAt = GETUTCDATE()
        WHERE UserID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_Users_GetById
    @Id INT
AS
BEGIN
    SELECT UserID, Email, PasswordHash, FullName, Phone, Bio, ProfilePhotoUrl, IsActive, CreatedAt, UpdatedAt
    FROM Users WHERE UserID = @Id;
END;

CREATE PROCEDURE usp_Users_GetByEmail
    @Email NVARCHAR(255)
AS
BEGIN
    SELECT UserID, Email, PasswordHash, FullName, Phone, Bio, ProfilePhotoUrl, IsActive, CreatedAt, UpdatedAt
    FROM Users WHERE Email = @Email;
END;

CREATE PROCEDURE usp_Users_GetAll
AS
BEGIN
    SELECT UserID, Email, PasswordHash, FullName, Phone, Bio, ProfilePhotoUrl, IsActive, CreatedAt, UpdatedAt
    FROM Users WHERE IsActive = 1;
END;

CREATE PROCEDURE usp_Users_Delete
    @Id INT
AS
BEGIN
    DELETE FROM Users WHERE UserID = @Id;
END;

CREATE PROCEDURE usp_Roles_Upsert
    @Id INT = 0,
    @RoleName NVARCHAR(100),
    @Description NVARCHAR(500) = NULL,
    @IsActive BIT = 1
AS
BEGIN
    IF @Id = 0
        INSERT INTO Roles (RoleName, Description, IsActive, CreatedAt)
        VALUES (@RoleName, @Description, @IsActive, GETUTCDATE());
    ELSE
        UPDATE Roles
        SET RoleName = @RoleName, Description = @Description, IsActive = @IsActive
        WHERE RoleID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_Roles_GetById
    @Id INT
AS
BEGIN
    SELECT RoleID, RoleName, Description, IsActive, CreatedAt
    FROM Roles WHERE RoleID = @Id;
END;

CREATE PROCEDURE usp_Roles_GetAll
AS
BEGIN
    SELECT RoleID, RoleName, Description, IsActive, CreatedAt
    FROM Roles WHERE IsActive = 1;
END;

CREATE PROCEDURE usp_UserRoles_AssignRole
    @UserId INT,
    @RoleId INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM UserRoles WHERE UserID = @UserId AND RoleID = @RoleId)
        INSERT INTO UserRoles (UserID, RoleID, AssignedAt)
        VALUES (@UserId, @RoleId, GETUTCDATE());

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_UserRoles_GetByUserId
    @UserId INT
AS
BEGIN
    SELECT r.RoleID, r.RoleName, r.Description, r.IsActive
    FROM UserRoles ur
    INNER JOIN Roles r ON ur.RoleID = r.RoleID
    WHERE ur.UserID = @UserId;
END;

CREATE PROCEDURE usp_UserRoles_RemoveRole
    @UserId INT,
    @RoleId INT
AS
BEGIN
    DELETE FROM UserRoles WHERE UserID = @UserId AND RoleID = @RoleId;
END;

-- ============================================
-- GALLERY TYPE PROCEDURES
-- ============================================

CREATE PROCEDURE usp_GalleryType_Upsert
    @Id INT = 0,
    @TypeName NVARCHAR(100),
    @Description NVARCHAR(500) = NULL,
    @IsActive BIT = 1
AS
BEGIN
    IF @Id = 0
        INSERT INTO GalleryType (TypeName, Description, IsActive, CreatedAt)
        VALUES (@TypeName, @Description, @IsActive, GETUTCDATE());
    ELSE
        UPDATE GalleryType
        SET TypeName = @TypeName, Description = @Description, IsActive = @IsActive
        WHERE GalleryTypeID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_GalleryType_GetAll
AS
BEGIN
    SELECT GalleryTypeID, TypeName, Description, IsActive
    FROM GalleryType
    WHERE IsActive = 1;
END;

CREATE PROCEDURE usp_GalleryType_GetById
    @Id INT
AS
BEGIN
    SELECT GalleryTypeID, TypeName, Description
    FROM GalleryType
    WHERE GalleryTypeID = @Id;
END;

-- ============================================
-- GALLERY PROCEDURES (Polymorphic)
-- ============================================

CREATE PROCEDURE usp_Gallery_Upsert
    @Id INT = 0,
    @GalleryTypeId INT,
    @EventId INT = NULL,
    @CreatedBy INT = NULL,
    @UpdatedBy INT = NULL,
    @Title NVARCHAR(255),
    @Description NVARCHAR(MAX) = NULL,
    @Category NVARCHAR(50) = NULL,
    @ThumbnailUrl NVARCHAR(500) = NULL,
    @DisplayOrder INT = 0,
    @IsFeatured BIT = 0,
    @IsPublished BIT = 1,
    @IsPrivate BIT = 0,
    @RotationSpeed INT = 5,
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @ReviewStatus NVARCHAR(50) = 'Draft',
    @ClientApprovalDeadline DATETIME = NULL,
    @ApprovedByUserID INT = NULL,
    @IsDeleted BIT = 0,
    @DeletedAt DATETIME = NULL,
    @DeletedBy INT = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO Gallery (GalleryTypeID, EventID, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, Title, Description, Category, ThumbnailUrl, DisplayOrder, IsFeatured, IsPublished, IsPrivate, ViewCount, RotationSpeed, StartDate, EndDate, ReviewStatus, ClientApprovalDeadline, ApprovedByUserID, ApprovedAt, IsDeleted, DeletedAt, DeletedBy)
        VALUES (@GalleryTypeId, @EventId, @CreatedBy, GETUTCDATE(), @UpdatedBy, GETUTCDATE(), @Title, @Description, @Category, @ThumbnailUrl, @DisplayOrder, @IsFeatured, @IsPublished, @IsPrivate, 0, @RotationSpeed, @StartDate, @EndDate, @ReviewStatus, @ClientApprovalDeadline, @ApprovedByUserID, CASE WHEN @ApprovedByUserID IS NOT NULL THEN GETUTCDATE() ELSE NULL END, @IsDeleted, @DeletedAt, @DeletedBy);
    ELSE
        UPDATE Gallery
        SET GalleryTypeID = @GalleryTypeId, EventID = @EventId, Title = @Title, Description = @Description, Category = @Category,
            ThumbnailUrl = @ThumbnailUrl, DisplayOrder = @DisplayOrder, IsFeatured = @IsFeatured, IsPublished = @IsPublished, IsPrivate = @IsPrivate,
            RotationSpeed = @RotationSpeed, StartDate = @StartDate, EndDate = @EndDate, UpdatedBy = @UpdatedBy, UpdatedAt = GETUTCDATE(),
            ReviewStatus = @ReviewStatus, ClientApprovalDeadline = @ClientApprovalDeadline, ApprovedByUserID = @ApprovedByUserID, ApprovedAt = CASE WHEN @ApprovedByUserID IS NOT NULL THEN GETUTCDATE() ELSE ApprovedAt END,
            IsDeleted = @IsDeleted, DeletedAt = @DeletedAt, DeletedBy = @DeletedBy
        WHERE GalleryID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_Gallery_GetById
    @Id INT
AS
BEGIN
    SELECT g.GalleryID, g.GalleryTypeID, gt.TypeName, g.EventID, g.CreatedBy, g.CreatedAt, g.UpdatedBy, g.UpdatedAt, g.Title, g.Description, g.Category,
            g.ThumbnailUrl, g.DisplayOrder, g.IsFeatured, g.IsPublished, g.IsPrivate, g.ViewCount,
            g.RotationSpeed, g.StartDate, g.EndDate, g.ReviewStatus, g.ClientApprovalDeadline, g.ApprovedByUserID, g.ApprovedAt,
            g.DeletedBy, g.DeletedAt, g.IsDeleted
    FROM Gallery g
    INNER JOIN GalleryType gt ON g.GalleryTypeID = gt.GalleryTypeID
    WHERE g.GalleryID = @Id AND g.IsDeleted = 0;
END;

CREATE PROCEDURE usp_Gallery_GetByType
    @TypeName NVARCHAR(100)
AS
BEGIN
    SELECT g.GalleryID, gt.TypeName, g.Title, g.Description, g.Category,
            g.ThumbnailUrl, g.DisplayOrder, g.IsFeatured, g.IsPublished, g.ViewCount
    FROM Gallery g
    INNER JOIN GalleryType gt ON g.GalleryTypeID = gt.GalleryTypeID
    WHERE gt.TypeName = @TypeName AND g.IsPublished = 1 AND g.IsDeleted = 0
    ORDER BY g.DisplayOrder, g.CreatedAt DESC;
END;

CREATE PROCEDURE usp_Gallery_GetByReviewStatus
    @ReviewStatus NVARCHAR(50)
AS
BEGIN
    SELECT g.GalleryID, g.GalleryTypeID, gt.TypeName, g.Title, g.Description, g.ReviewStatus, g.ClientApprovalDeadline, g.ApprovedByUserID, g.ApprovedAt, g.CreatedAt
    FROM Gallery g
    INNER JOIN GalleryType gt ON g.GalleryTypeID = gt.GalleryTypeID
    WHERE g.ReviewStatus = @ReviewStatus AND g.IsDeleted = 0
    ORDER BY g.CreatedAt DESC;
END;

CREATE PROCEDURE usp_Gallery_Approve
    @GalleryID INT,
    @ApprovedByUserID INT
AS
BEGIN
    UPDATE Gallery
    SET ReviewStatus = 'ApprovedByClient', ApprovedByUserID = @ApprovedByUserID, ApprovedAt = GETUTCDATE()
    WHERE GalleryID = @GalleryID;
END;

CREATE PROCEDURE usp_Gallery_GetFeatured
    @TypeName NVARCHAR(100) = NULL
AS
BEGIN
    IF @TypeName IS NULL
        SELECT TOP 6 g.GalleryID, gt.TypeName, g.Title, g.ThumbnailUrl, g.DisplayOrder, g.ViewCount
        FROM Gallery g
        INNER JOIN GalleryType gt ON g.GalleryTypeID = gt.GalleryTypeID
        WHERE g.IsFeatured = 1 AND g.IsPublished = 1 AND g.IsDeleted = 0
        ORDER BY g.DisplayOrder;
    ELSE
        SELECT TOP 6 g.GalleryID, gt.TypeName, g.Title, g.ThumbnailUrl, g.DisplayOrder, g.ViewCount
        FROM Gallery g
        INNER JOIN GalleryType gt ON g.GalleryTypeID = gt.GalleryTypeID
        WHERE gt.TypeName = @TypeName AND g.IsFeatured = 1 AND g.IsPublished = 1 AND g.IsDeleted = 0
        ORDER BY g.DisplayOrder;
END;

CREATE PROCEDURE usp_Gallery_GetPaged
    @TypeName NVARCHAR(100) = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    IF @TypeName IS NULL
        SELECT g.GalleryID, gt.TypeName, g.Title, g.Description, g.ThumbnailUrl, g.DisplayOrder, g.ViewCount
        FROM Gallery g
        INNER JOIN GalleryType gt ON g.GalleryTypeID = gt.GalleryTypeID
        WHERE g.IsPublished = 1 AND g.IsDeleted = 0
        ORDER BY g.DisplayOrder, g.CreatedAt DESC
        OFFSET (@PageNumber - 1) * @PageSize ROWS
        FETCH NEXT @PageSize ROWS ONLY;
    ELSE
        SELECT g.GalleryID, gt.TypeName, g.Title, g.Description, g.ThumbnailUrl, g.DisplayOrder, g.ViewCount
        FROM Gallery g
        INNER JOIN GalleryType gt ON g.GalleryTypeID = gt.GalleryTypeID
        WHERE gt.TypeName = @TypeName AND g.IsPublished = 1 AND g.IsDeleted = 0
        ORDER BY g.DisplayOrder, g.CreatedAt DESC
        OFFSET (@PageNumber - 1) * @PageSize ROWS
        FETCH NEXT @PageSize ROWS ONLY;

    SELECT COUNT(*) AS TotalCount
    FROM Gallery g
    INNER JOIN GalleryType gt ON g.GalleryTypeID = gt.GalleryTypeID
    WHERE g.IsPublished = 1 AND g.IsDeleted = 0 AND (@TypeName IS NULL OR gt.TypeName = @TypeName);
END;

CREATE PROCEDURE usp_Gallery_Delete
    @Id INT
AS
BEGIN
    DELETE FROM GalleryAsset WHERE GalleryID = @Id;
    DELETE FROM Gallery WHERE GalleryID = @Id;
END;

CREATE PROCEDURE usp_Gallery_IncrementViewCount
    @Id INT
AS
BEGIN
    UPDATE Gallery
    SET ViewCount = ViewCount + 1
    WHERE GalleryID = @Id;
END;

-- ============================================
-- GALLERY ASSET PROCEDURES
-- ============================================

CREATE PROCEDURE usp_GalleryAsset_Upsert
    @Id INT = 0,
    @GalleryId INT,
    @AssetType NVARCHAR(50),
    @MediaUrl NVARCHAR(500),
    @ThumbnailUrl NVARCHAR(500) = NULL,
    @LinkUrl NVARCHAR(500) = NULL,
    @AltText NVARCHAR(255) = NULL,
    @Caption NVARCHAR(500) = NULL,
    @DurationMinutes INT = NULL,
    @DisplayOrder INT = 0,
    @CreatedBy INT,
    @AssetStatus NVARCHAR(50) = 'Original',
    @RetouchNotes NVARCHAR(MAX) = NULL,
    @IsDeleted BIT = 0,
    @DeletedAt DATETIME = NULL,
    @DeletedBy INT = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO GalleryAsset (GalleryID, AssetType, MediaUrl, ThumbnailUrl, LinkUrl, AltText, Caption, DurationMinutes, DisplayOrder, CreatedBy, UploadedAt, AssetStatus, RetouchNotes, IsDeleted, DeletedAt, DeletedBy)
        VALUES (@GalleryId, @AssetType, @MediaUrl, @ThumbnailUrl, @LinkUrl, @AltText, @Caption, @DurationMinutes, @DisplayOrder, @CreatedBy, GETUTCDATE(), @AssetStatus, @RetouchNotes, @IsDeleted, @DeletedAt, @DeletedBy);
    ELSE
        UPDATE GalleryAsset
        SET GalleryID = @GalleryId, AssetType = @AssetType, MediaUrl = @MediaUrl, ThumbnailUrl = @ThumbnailUrl,
            LinkUrl = @LinkUrl, AltText = @AltText, Caption = @Caption, DurationMinutes = @DurationMinutes,
            DisplayOrder = @DisplayOrder, AssetStatus = @AssetStatus, RetouchNotes = @RetouchNotes,
            IsDeleted = @IsDeleted, DeletedAt = @DeletedAt, DeletedBy = @DeletedBy
        WHERE AssetID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_GalleryAsset_GetByGallery
    @GalleryId INT
AS
BEGIN
    SELECT AssetID, GalleryID, AssetType, MediaUrl, ThumbnailUrl, LinkUrl, AltText, Caption, DurationMinutes, DisplayOrder, CreatedBy, UploadedAt, DeletedBy, DeletedAt, IsDeleted
    FROM GalleryAsset
    WHERE GalleryID = @GalleryId AND IsDeleted = 0
    ORDER BY DisplayOrder;
END;

CREATE PROCEDURE usp_GalleryAsset_GetById
    @Id INT
AS
BEGIN
    SELECT AssetID, GalleryID, AssetType, MediaUrl, ThumbnailUrl, LinkUrl, AltText, Caption, DurationMinutes, DisplayOrder, AssetStatus, RetouchNotes, DeletedBy, DeletedAt, IsDeleted
    FROM GalleryAsset
    WHERE AssetID = @Id AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_GalleryAsset_GetByStatus
    @AssetStatus NVARCHAR(50)
AS
BEGIN
    SELECT AssetID, GalleryID, AssetType, MediaUrl, ThumbnailUrl, LinkUrl, AltText, Caption, DurationMinutes, DisplayOrder, AssetStatus, RetouchNotes, UploadedAt
    FROM GalleryAsset
    WHERE AssetStatus = @AssetStatus
    ORDER BY UploadedAt DESC;
END;

CREATE PROCEDURE usp_GalleryAsset_UpdateStatus
    @AssetID INT,
    @AssetStatus NVARCHAR(50),
    @RetouchNotes NVARCHAR(MAX) = NULL
AS
BEGIN
    UPDATE GalleryAsset
    SET AssetStatus = @AssetStatus, RetouchNotes = @RetouchNotes
    WHERE AssetID = @AssetID;
END;

CREATE PROCEDURE usp_GalleryAsset_GetByGalleryAndType
    @GalleryId INT,
    @AssetType NVARCHAR(50)
AS
BEGIN
    SELECT AssetID, GalleryID, AssetType, MediaUrl, ThumbnailUrl, LinkUrl, AltText, Caption, DurationMinutes, DisplayOrder
    FROM GalleryAsset
    WHERE GalleryID = @GalleryId AND AssetType = @AssetType
    ORDER BY DisplayOrder;
END;

CREATE PROCEDURE usp_GalleryAsset_Delete
    @Id INT
AS
BEGIN
    DELETE FROM GalleryAsset WHERE AssetID = @Id;
END;

CREATE PROCEDURE usp_GalleryAsset_Reorder
    @GalleryId INT,
    @AssetId INT,
    @NewOrder INT
AS
BEGIN
    UPDATE GalleryAsset
    SET DisplayOrder = @NewOrder
    WHERE AssetID = @AssetId AND GalleryID = @GalleryId;
END;

-- ============================================
-- GALLERY REPORTING PROCEDURES
-- ============================================

CREATE PROCEDURE usp_Gallery_GetStats
    @TypeName NVARCHAR(100) = NULL
AS
BEGIN
    SELECT
        gt.TypeName,
        COUNT(DISTINCT g.GalleryID) AS GalleryCount,
        COUNT(DISTINCT ga.AssetID) AS TotalAssets,
        SUM(g.ViewCount) AS TotalViews
    FROM Gallery g
    INNER JOIN GalleryType gt ON g.GalleryTypeID = gt.GalleryTypeID
    LEFT JOIN GalleryAsset ga ON g.GalleryID = ga.GalleryID
    WHERE @TypeName IS NULL OR gt.TypeName = @TypeName
    GROUP BY gt.TypeName;
END;

CREATE PROCEDURE usp_Gallery_GetMostViewed
    @TypeName NVARCHAR(100) = NULL,
    @TopCount INT = 10
AS
BEGIN
    SELECT TOP (@TopCount)
        g.GalleryID, gt.TypeName, g.Title, g.ThumbnailUrl, g.ViewCount
    FROM Gallery g
    INNER JOIN GalleryType gt ON g.GalleryTypeID = gt.GalleryTypeID
    WHERE g.IsPublished = 1 AND (@TypeName IS NULL OR gt.TypeName = @TypeName)
    ORDER BY g.ViewCount DESC;
END;

-- ============================================
-- PHOTOGRAPHY PACKAGE PROCEDURES
-- ============================================

CREATE PROCEDURE usp_PhotographyPackage_Upsert
    @Id INT = 0,
    @PackageName NVARCHAR(255),
    @PackageDescription NVARCHAR(MAX) = NULL,
    @BasePrice DECIMAL(10,2),
    @Currency NVARCHAR(10) = 'INR',
    @DurationHours INT = NULL,
    @MaxGalleryImages INT = NULL,
    @MaxVideoDurationMinutes INT = NULL,
    @IncludedRawFiles BIT = 0,
    @IncludedAlbum BIT = 0,
    @IncludedRetouching BIT = 0,
    @RetouchingLevel NVARCHAR(50) = NULL,
    @IncludedSecondPhotographer BIT = 0,
    @IsActive BIT = 1,
    @IsFeatured BIT = 0,
    @DisplayOrder INT = 0,
    @CreatedBy INT = NULL,
    @UpdatedBy INT = NULL,
    @IsDeleted BIT = 0,
    @DeletedAt DATETIME = NULL,
    @DeletedBy INT = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO PhotographyPackage (PackageName, PackageDescription, BasePrice, Currency, DurationHours, MaxGalleryImages,
                                       MaxVideoDurationMinutes, IncludedRawFiles, IncludedAlbum, IncludedRetouching, RetouchingLevel,
                                       IncludedSecondPhotographer, IsActive, IsFeatured, DisplayOrder, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt,
                                       IsDeleted, DeletedAt, DeletedBy)
        VALUES (@PackageName, @PackageDescription, @BasePrice, @Currency, @DurationHours, @MaxGalleryImages,
                @MaxVideoDurationMinutes, @IncludedRawFiles, @IncludedAlbum, @IncludedRetouching, @RetouchingLevel,
                @IncludedSecondPhotographer, @IsActive, @IsFeatured, @DisplayOrder, @CreatedBy, GETUTCDATE(), @UpdatedBy, GETUTCDATE(),
                @IsDeleted, @DeletedAt, @DeletedBy);
    ELSE
        UPDATE PhotographyPackage
        SET PackageName = @PackageName, PackageDescription = @PackageDescription, BasePrice = @BasePrice, Currency = @Currency,
            DurationHours = @DurationHours, MaxGalleryImages = @MaxGalleryImages, MaxVideoDurationMinutes = @MaxVideoDurationMinutes,
            IncludedRawFiles = @IncludedRawFiles, IncludedAlbum = @IncludedAlbum, IncludedRetouching = @IncludedRetouching,
            RetouchingLevel = @RetouchingLevel, IncludedSecondPhotographer = @IncludedSecondPhotographer, IsActive = @IsActive,
            IsFeatured = @IsFeatured, DisplayOrder = @DisplayOrder, UpdatedBy = @UpdatedBy, UpdatedAt = GETUTCDATE(),
            IsDeleted = @IsDeleted, DeletedAt = @DeletedAt, DeletedBy = @DeletedBy
        WHERE PackageID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_PhotographyPackage_GetById
    @Id INT
AS
BEGIN
    SELECT PackageID, PackageName, PackageDescription, BasePrice, Currency, DurationHours, MaxGalleryImages, MaxVideoDurationMinutes,
           IncludedRawFiles, IncludedAlbum, IncludedRetouching, RetouchingLevel, IncludedSecondPhotographer, IsActive, IsFeatured,
           DisplayOrder, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM PhotographyPackage WHERE PackageID = @Id AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_PhotographyPackage_GetActive
AS
BEGIN
    SELECT PackageID, PackageName, PackageDescription, BasePrice, Currency, DurationHours, MaxGalleryImages, MaxVideoDurationMinutes,
           IncludedRawFiles, IncludedAlbum, IncludedRetouching, RetouchingLevel, IncludedSecondPhotographer, IsActive, IsFeatured,
           DisplayOrder, CreatedAt, UpdatedAt
    FROM PhotographyPackage WHERE IsActive = 1 AND IsDeleted = 0
    ORDER BY DisplayOrder;
END;

CREATE PROCEDURE usp_PhotographyPackage_GetPaged
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SELECT PackageID, PackageName, PackageDescription, BasePrice, Currency, DurationHours, MaxGalleryImages, MaxVideoDurationMinutes,
           IncludedRawFiles, IncludedAlbum, IncludedRetouching, RetouchingLevel, IncludedSecondPhotographer, IsActive, IsFeatured,
           DisplayOrder, CreatedAt, UpdatedAt
    FROM PhotographyPackage
    WHERE IsDeleted = 0
    ORDER BY DisplayOrder, CreatedAt DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    SELECT COUNT(*) AS TotalCount FROM PhotographyPackage WHERE IsDeleted = 0;
END;

CREATE PROCEDURE usp_PhotographyPackage_Delete
    @Id INT
AS
BEGIN
    DELETE FROM PackageDiscount WHERE PackageID = @Id;
    DELETE FROM PackageAddOn WHERE PackageID = @Id;
    DELETE FROM PackageComponent WHERE PackageID = @Id;
    DELETE FROM PhotographyPackage WHERE PackageID = @Id;
END;

-- ============================================
-- PACKAGE COMPONENT PROCEDURES
-- ============================================

CREATE PROCEDURE usp_PackageComponent_Upsert
    @Id INT = 0,
    @PackageId INT,
    @ComponentType NVARCHAR(100) = NULL,
    @ComponentName NVARCHAR(255),
    @ComponentDescription NVARCHAR(MAX) = NULL,
    @Quantity INT = NULL,
    @Unit NVARCHAR(50) = NULL,
    @AddedValue DECIMAL(10,2) = NULL,
    @IsIncludedByDefault BIT = 1,
    @DisplayOrder INT = 0,
    @CreatedBy INT = NULL,
    @UpdatedBy INT = NULL,
    @IsDeleted BIT = 0,
    @DeletedAt DATETIME = NULL,
    @DeletedBy INT = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO PackageComponent (PackageID, ComponentType, ComponentName, ComponentDescription, Quantity, Unit, AddedValue,
                                     IsIncludedByDefault, DisplayOrder, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, IsDeleted, DeletedAt, DeletedBy)
        VALUES (@PackageId, @ComponentType, @ComponentName, @ComponentDescription, @Quantity, @Unit, @AddedValue,
                @IsIncludedByDefault, @DisplayOrder, @CreatedBy, GETUTCDATE(), @UpdatedBy, GETUTCDATE(), @IsDeleted, @DeletedAt, @DeletedBy);
    ELSE
        UPDATE PackageComponent
        SET PackageID = @PackageId, ComponentType = @ComponentType, ComponentName = @ComponentName, ComponentDescription = @ComponentDescription,
            Quantity = @Quantity, Unit = @Unit, AddedValue = @AddedValue, IsIncludedByDefault = @IsIncludedByDefault,
            DisplayOrder = @DisplayOrder, UpdatedBy = @UpdatedBy, UpdatedAt = GETUTCDATE(),
            IsDeleted = @IsDeleted, DeletedAt = @DeletedAt, DeletedBy = @DeletedBy
        WHERE ComponentID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_PackageComponent_GetById
    @Id INT
AS
BEGIN
    SELECT ComponentID, PackageID, ComponentType, ComponentName, ComponentDescription, Quantity, Unit, AddedValue,
           IsIncludedByDefault, DisplayOrder, CreatedAt, CreatedBy, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM PackageComponent WHERE ComponentID = @Id AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_PackageComponent_GetByPackage
    @PackageId INT
AS
BEGIN
    SELECT ComponentID, PackageID, ComponentType, ComponentName, ComponentDescription, Quantity, Unit, AddedValue,
           IsIncludedByDefault, DisplayOrder, CreatedAt, CreatedBy, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM PackageComponent WHERE PackageID = @PackageId AND IsDeleted = 0
    ORDER BY DisplayOrder;
END;

CREATE PROCEDURE usp_PackageComponent_Delete
    @Id INT
AS
BEGIN
    DELETE FROM PackageComponent WHERE ComponentID = @Id;
END;

-- ============================================
-- PACKAGE ADD-ON PROCEDURES
-- ============================================

CREATE PROCEDURE usp_PackageAddOn_Upsert
    @Id INT = 0,
    @PackageId INT,
    @AddOnName NVARCHAR(255),
    @AddOnDescription NVARCHAR(MAX) = NULL,
    @Price DECIMAL(10,2),
    @Category NVARCHAR(100) = NULL,
    @MaxQuantity INT = NULL,
    @IsFeatured BIT = 0,
    @DisplayOrder INT = 0,
    @IsActive BIT = 1,
    @CreatedBy INT = NULL,
    @UpdatedBy INT = NULL,
    @IsDeleted BIT = 0,
    @DeletedAt DATETIME = NULL,
    @DeletedBy INT = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO PackageAddOn (PackageID, AddOnName, AddOnDescription, Price, Category, MaxQuantity, IsFeatured, DisplayOrder, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, IsDeleted, DeletedAt, DeletedBy)
        VALUES (@PackageId, @AddOnName, @AddOnDescription, @Price, @Category, @MaxQuantity, @IsFeatured, @DisplayOrder, @IsActive, @CreatedBy, GETUTCDATE(), @UpdatedBy, GETUTCDATE(), @IsDeleted, @DeletedAt, @DeletedBy);
    ELSE
        UPDATE PackageAddOn
        SET PackageID = @PackageId, AddOnName = @AddOnName, AddOnDescription = @AddOnDescription, Price = @Price, Category = @Category,
            MaxQuantity = @MaxQuantity, IsFeatured = @IsFeatured, DisplayOrder = @DisplayOrder, IsActive = @IsActive,
            UpdatedBy = @UpdatedBy, UpdatedAt = GETUTCDATE(),
            IsDeleted = @IsDeleted, DeletedAt = @DeletedAt, DeletedBy = @DeletedBy
        WHERE AddOnID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_PackageAddOn_GetById
    @Id INT
AS
BEGIN
    SELECT AddOnID, PackageID, AddOnName, AddOnDescription, Price, Category, MaxQuantity, IsFeatured, DisplayOrder, IsActive, CreatedAt, CreatedBy, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM PackageAddOn WHERE AddOnID = @Id AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_PackageAddOn_GetByPackage
    @PackageId INT
AS
BEGIN
    SELECT AddOnID, PackageID, AddOnName, AddOnDescription, Price, Category, MaxQuantity, IsFeatured, DisplayOrder, IsActive, CreatedAt, CreatedBy, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM PackageAddOn WHERE PackageID = @PackageId AND IsActive = 1 AND IsDeleted = 0
    ORDER BY DisplayOrder;
END;

CREATE PROCEDURE usp_PackageAddOn_Delete
    @Id INT
AS
BEGIN
    DELETE FROM PackageAddOn WHERE AddOnID = @Id;
END;

-- ============================================
-- PACKAGE DISCOUNT PROCEDURES
-- ============================================

CREATE PROCEDURE usp_PackageDiscount_Upsert
    @Id INT = 0,
    @PackageId INT,
    @DiscountName NVARCHAR(255),
    @DiscountType NVARCHAR(50) = NULL,
    @DiscountValue DECIMAL(10,2),
    @ValidFrom DATETIME = NULL,
    @ValidTo DATETIME = NULL,
    @IsActive BIT = 1,
    @CreatedBy INT = NULL,
    @UpdatedBy INT = NULL,
    @IsDeleted BIT = 0,
    @DeletedAt DATETIME = NULL,
    @DeletedBy INT = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO PackageDiscount (PackageID, DiscountName, DiscountType, DiscountValue, ValidFrom, ValidTo, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, IsDeleted, DeletedAt, DeletedBy)
        VALUES (@PackageId, @DiscountName, @DiscountType, @DiscountValue, @ValidFrom, @ValidTo, @IsActive, @CreatedBy, GETUTCDATE(), @UpdatedBy, GETUTCDATE(), @IsDeleted, @DeletedAt, @DeletedBy);
    ELSE
        UPDATE PackageDiscount
        SET PackageID = @PackageId, DiscountName = @DiscountName, DiscountType = @DiscountType, DiscountValue = @DiscountValue,
            ValidFrom = @ValidFrom, ValidTo = @ValidTo, IsActive = @IsActive, UpdatedBy = @UpdatedBy, UpdatedAt = GETUTCDATE(),
            IsDeleted = @IsDeleted, DeletedAt = @DeletedAt, DeletedBy = @DeletedBy
        WHERE DiscountID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_PackageDiscount_GetById
    @Id INT
AS
BEGIN
    SELECT DiscountID, PackageID, DiscountName, DiscountType, DiscountValue, ValidFrom, ValidTo, IsActive, CreatedAt, UpdatedAt, CreatedBy, UpdatedBy, DeletedBy, DeletedAt, IsDeleted
    FROM PackageDiscount WHERE DiscountID = @Id AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_PackageDiscount_GetByPackage
    @PackageId INT
AS
BEGIN
    SELECT DiscountID, PackageID, DiscountName, DiscountType, DiscountValue, ValidFrom, ValidTo, IsActive, CreatedAt, UpdatedAt, CreatedBy, UpdatedBy, DeletedBy, DeletedAt, IsDeleted
    FROM PackageDiscount WHERE PackageID = @PackageId AND IsDeleted = 0
    ORDER BY DiscountName;
END;

CREATE PROCEDURE usp_PackageDiscount_GetByPackageActive
    @PackageId INT,
    @CurrentDate DATETIME = NULL
AS
BEGIN
    IF @CurrentDate IS NULL SET @CurrentDate = GETUTCDATE();

    SELECT DiscountID, PackageID, DiscountName, DiscountType, DiscountValue, ValidFrom, ValidTo, IsActive, CreatedAt, UpdatedAt, CreatedBy, UpdatedBy, DeletedBy, DeletedAt, IsDeleted
    FROM PackageDiscount
    WHERE PackageID = @PackageId AND IsActive = 1 AND IsDeleted = 0
      AND (@ValidFrom IS NULL OR ValidFrom <= @CurrentDate)
      AND (@ValidTo IS NULL OR ValidTo >= @CurrentDate);
END;

CREATE PROCEDURE usp_PackageDiscount_Delete
    @Id INT
AS
BEGIN
    DELETE FROM PackageDiscount WHERE DiscountID = @Id;
END;

-- ============================================
-- CLIENT INFO PROCEDURES
-- ============================================

CREATE PROCEDURE usp_ClientInfo_Upsert
    @Id INT = 0,
    @Email NVARCHAR(255),
    @Phone NVARCHAR(20) = NULL,
    @FullName NVARCHAR(255),
    @Address NVARCHAR(500) = NULL,
    @PreferredContactMethod NVARCHAR(50) = NULL,
    @CreatedBy INT = NULL,
    @UpdatedBy INT = NULL,
    @DeletedBy INT = NULL,
    @DeletedAt DATETIME = NULL,
    @IsDeleted BIT = 0
AS
BEGIN
    IF @Id = 0
        INSERT INTO ClientInfo (Email, Phone, FullName, Address, PreferredContactMethod, PreviousBookings, CreatedAt, UpdatedAt, CreatedBy, UpdatedBy, DeletedBy, DeletedAt, IsDeleted)
        VALUES (@Email, @Phone, @FullName, @Address, @PreferredContactMethod, 0, GETUTCDATE(), GETUTCDATE(), @CreatedBy, @UpdatedBy, @DeletedBy, @DeletedAt, @IsDeleted);
    ELSE
        UPDATE ClientInfo
        SET Email = @Email, Phone = @Phone, FullName = @FullName, Address = @Address, PreferredContactMethod = @PreferredContactMethod,
            UpdatedAt = GETUTCDATE(), UpdatedBy = @UpdatedBy, DeletedBy = @DeletedBy, DeletedAt = @DeletedAt, IsDeleted = @IsDeleted
        WHERE ClientID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_ClientInfo_GetById
    @Id INT
AS
BEGIN
    SELECT ClientID, Email, Phone, FullName, Address, PreferredContactMethod, PreviousBookings, CreatedAt, UpdatedAt, CreatedBy, UpdatedBy, DeletedBy, DeletedAt, IsDeleted
    FROM ClientInfo WHERE ClientID = @Id;
END;

CREATE PROCEDURE usp_ClientInfo_GetByEmail
    @Email NVARCHAR(255)
AS
BEGIN
    SELECT ClientID, Email, Phone, FullName, Address, PreferredContactMethod, PreviousBookings, CreatedAt, UpdatedAt
    FROM ClientInfo WHERE Email = @Email;
END;

CREATE PROCEDURE usp_ClientInfo_GetPaged
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SELECT ClientID, Email, Phone, FullName, Address, PreferredContactMethod, PreviousBookings, CreatedAt, UpdatedAt, CreatedBy, UpdatedBy, DeletedBy, DeletedAt, IsDeleted
    FROM ClientInfo
    WHERE IsDeleted = 0
    ORDER BY CreatedAt DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    SELECT COUNT(*) AS TotalCount FROM ClientInfo WHERE IsDeleted = 0;
END;

CREATE PROCEDURE usp_ClientInfo_GetDeleted
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SELECT ClientID, Email, Phone, FullName, Address, PreferredContactMethod, PreviousBookings, CreatedAt, UpdatedAt, CreatedBy, UpdatedBy, DeletedBy, DeletedAt, IsDeleted
    FROM ClientInfo
    WHERE IsDeleted = 1
    ORDER BY DeletedAt DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    SELECT COUNT(*) AS TotalCount FROM ClientInfo WHERE IsDeleted = 1;
END;

CREATE PROCEDURE usp_ClientInfo_Delete
    @Id INT
AS
BEGIN
    DELETE FROM ClientInfo WHERE ClientID = @Id;
END;

-- ============================================
-- BOOKING PROCEDURES
-- ============================================

CREATE PROCEDURE usp_Booking_Upsert
    @Id INT = 0,
    @PackageId INT,
    @ClientId INT,
    @QuotationId INT,
    @PhotographerUserId INT,
    @BookingDate DATETIME,
    @Location NVARCHAR(500) = NULL,
    @Status NVARCHAR(50) = 'Confirmed',
    @TotalPrice DECIMAL(10,2),
    @SpecialRequests NVARCHAR(MAX) = NULL,
    @Notes NVARCHAR(MAX) = NULL,
    @CreatedBy INT,
    @UpdatedBy INT = NULL,
    @IsDeleted BIT = 0,
    @DepositAmount DECIMAL(10,2) = NULL,
    @DepositPaid BIT = 0
AS
BEGIN
    IF @Id = 0
        INSERT INTO Booking (PackageID, ClientID, QuotationID, PhotographerUserID, BookingDate, Location, Status, TotalPrice, SpecialRequests, Notes, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, IsDeleted, DepositAmount, DepositPaid)
        VALUES (@PackageId, @ClientId, @QuotationId, @PhotographerUserId, @BookingDate, @Location, @Status, @TotalPrice, @SpecialRequests, @Notes, @CreatedBy, GETUTCDATE(), @UpdatedBy, GETUTCDATE(), @IsDeleted, @DepositAmount, @DepositPaid);
    ELSE
        UPDATE Booking
        SET PackageID = @PackageId, ClientID = @ClientId, QuotationID = @QuotationId, PhotographerUserID = @PhotographerUserId,
            BookingDate = @BookingDate, Location = @Location, Status = @Status,
            TotalPrice = @TotalPrice, SpecialRequests = @SpecialRequests, Notes = @Notes, UpdatedBy = @UpdatedBy, UpdatedAt = GETUTCDATE(),
            IsDeleted = @IsDeleted, DepositAmount = @DepositAmount, DepositPaid = @DepositPaid
        WHERE BookingID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_Booking_GetById
    @Id INT
AS
BEGIN
    SELECT BookingID, PackageID, ClientID, QuotationID, PhotographerUserID, BookingDate, Location, Status, TotalPrice, SpecialRequests, Notes, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted, DepositAmount, DepositPaid
    FROM Booking WHERE BookingID = @Id AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_Booking_GetPaged
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SELECT BookingID, PackageID, ClientID, QuotationID, PhotographerUserID, BookingDate, Location, Status, TotalPrice, SpecialRequests, Notes, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM Booking
    WHERE IsDeleted = 0
    ORDER BY BookingDate DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    SELECT COUNT(*) AS TotalCount FROM Booking WHERE IsDeleted = 0;
END;

CREATE PROCEDURE usp_Booking_GetByDateRange
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    SELECT BookingID, PackageID, ClientID, QuotationID, PhotographerUserID, BookingDate, Location, Status, TotalPrice, SpecialRequests, Notes, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM Booking
    WHERE BookingDate BETWEEN @StartDate AND @EndDate AND IsDeleted = 0
    ORDER BY BookingDate;
END;

CREATE PROCEDURE usp_Booking_Delete
    @Id INT,
    @DeletedBy INT
AS
BEGIN
    UPDATE Booking
    SET IsDeleted = 1, DeletedBy = @DeletedBy, DeletedAt = GETUTCDATE()
    WHERE BookingID = @Id AND IsDeleted = 0;
END;

-- ============================================
-- BOOKING PACKAGE PROCEDURES
-- ============================================

CREATE PROCEDURE usp_BookingPackage_Upsert
    @Id INT = 0,
    @BookingId INT,
    @PackageId INT,
    @SelectedAddOnsJson NVARCHAR(MAX) = NULL,
    @AppliedDiscount DECIMAL(10,2) = 0,
    @FinalPrice DECIMAL(10,2),
    @PackageSnapshot NVARCHAR(MAX) = NULL,
    @CampaignID INT = NULL,
    @IsDeleted BIT = 0,
    @DeletedAt DATETIME = NULL,
    @DeletedBy INT = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO BookingPackage (BookingID, PackageID, SelectedAddOnsJson, AppliedDiscount, FinalPrice, PackageSnapshot, CampaignID, CreatedAt, IsDeleted, DeletedAt, DeletedBy)
        VALUES (@BookingId, @PackageId, @SelectedAddOnsJson, @AppliedDiscount, @FinalPrice, @PackageSnapshot, @CampaignID, GETUTCDATE(), @IsDeleted, @DeletedAt, @DeletedBy);
    ELSE
        UPDATE BookingPackage
        SET BookingID = @BookingId, PackageID = @PackageId, SelectedAddOnsJson = @SelectedAddOnsJson,
            AppliedDiscount = @AppliedDiscount, FinalPrice = @FinalPrice, PackageSnapshot = @PackageSnapshot, CampaignID = @CampaignID,
            IsDeleted = @IsDeleted, DeletedAt = @DeletedAt, DeletedBy = @DeletedBy
        WHERE BookingPackageID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_BookingPackage_GetByBooking
    @BookingId INT
AS
BEGIN
    SELECT BookingPackageID, BookingID, PackageID, SelectedAddOnsJson, AppliedDiscount, FinalPrice, PackageSnapshot, CampaignID, CreatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM BookingPackage WHERE BookingID = @BookingId AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_BookingPackage_GetByCampaign
    @CampaignID INT
AS
BEGIN
    SELECT BookingPackageID, BookingID, PackageID, SelectedAddOnsJson, AppliedDiscount, FinalPrice, PackageSnapshot, CampaignID, CreatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM BookingPackage WHERE CampaignID = @CampaignID AND IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

-- ============================================
-- CALENDAR BLOCK PROCEDURES
-- ============================================

CREATE PROCEDURE usp_CalendarBlock_Upsert
    @Id INT = 0,
    @BookingId INT = NULL,
    @BlockStart DATETIME,
    @BlockEnd DATETIME,
    @Status NVARCHAR(50) = 'Booked',
    @BlockReason NVARCHAR(255) = NULL,
    @IsDeleted BIT = 0,
    @DeletedAt DATETIME = NULL,
    @DeletedBy INT = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO CalendarBlock (BookingID, BlockStart, BlockEnd, Status, BlockReason, CreatedAt, IsDeleted, DeletedAt, DeletedBy)
        VALUES (@BookingId, @BlockStart, @BlockEnd, @Status, @BlockReason, GETUTCDATE(), @IsDeleted, @DeletedAt, @DeletedBy);
    ELSE
        UPDATE CalendarBlock
        SET BookingID = @BookingId, BlockStart = @BlockStart, BlockEnd = @BlockEnd,
            Status = @Status, BlockReason = @BlockReason,
            IsDeleted = @IsDeleted, DeletedAt = @DeletedAt, DeletedBy = @DeletedBy
        WHERE BlockID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_CalendarBlock_GetByDateRange
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    SELECT BlockID, BookingID, BlockStart, BlockEnd, Status, BlockReason, CreatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM CalendarBlock
    WHERE BlockStart < @EndDate AND BlockEnd > @StartDate AND IsDeleted = 0
    ORDER BY BlockStart;
END;

CREATE PROCEDURE usp_CalendarBlock_CheckAvailability
    @PhotographerUserID INT,
    @BlockStart DATETIME,
    @BlockEnd DATETIME
AS
BEGIN
    SELECT COUNT(*) AS ConflictingBlocks
    FROM CalendarBlock cb
    INNER JOIN Booking b ON cb.BookingID = b.BookingID
    WHERE b.PhotographerUserID = @PhotographerUserID
      AND cb.BlockStart < @BlockEnd
      AND cb.BlockEnd > @BlockStart
      AND cb.Status IN ('Booked', 'Hold')
      AND cb.IsDeleted = 0;
END;

CREATE PROCEDURE usp_CalendarBlock_Delete
    @Id INT
AS
BEGIN
    DELETE FROM CalendarBlock WHERE BlockID = @Id;
END;

-- ============================================
-- AVAILABILITY PROCEDURES
-- ============================================

CREATE PROCEDURE usp_Availability_Upsert
    @Id INT = 0,
    @PhotographerUserID INT,
    @AvailabilityStart DATETIME,
    @AvailabilityEnd DATETIME,
    @IsAvailable BIT = 1,
    @Notes NVARCHAR(500) = NULL,
    @IsDeleted BIT = 0,
    @DeletedAt DATETIME = NULL,
    @DeletedBy INT = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO Availability (PhotographerUserID, AvailabilityStart, AvailabilityEnd, IsAvailable, Notes, CreatedAt, UpdatedAt, IsDeleted, DeletedAt, DeletedBy)
        VALUES (@PhotographerUserID, @AvailabilityStart, @AvailabilityEnd, @IsAvailable, @Notes, GETUTCDATE(), GETUTCDATE(), @IsDeleted, @DeletedAt, @DeletedBy);
    ELSE
        UPDATE Availability
        SET PhotographerUserID = @PhotographerUserID, AvailabilityStart = @AvailabilityStart, AvailabilityEnd = @AvailabilityEnd, IsAvailable = @IsAvailable, Notes = @Notes, UpdatedAt = GETUTCDATE(),
            IsDeleted = @IsDeleted, DeletedAt = @DeletedAt, DeletedBy = @DeletedBy
        WHERE AvailabilityID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_Availability_GetByDateRange
    @PhotographerUserID INT,
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    SELECT AvailabilityID, PhotographerUserID, AvailabilityStart, AvailabilityEnd, IsAvailable, Notes, CreatedAt, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM Availability
    WHERE PhotographerUserID = @PhotographerUserID
      AND AvailabilityStart <= @EndDate
      AND AvailabilityEnd >= @StartDate
      AND IsDeleted = 0
    ORDER BY AvailabilityStart;
END;

CREATE PROCEDURE usp_Availability_Delete
    @Id INT
AS
BEGIN
    DELETE FROM Availability WHERE AvailabilityID = @Id;
END;

-- ============================================
-- DAILY TASK PROCEDURES
-- ============================================

CREATE PROCEDURE usp_DailyTask_Upsert
    @Id INT = 0,
    @BookingId INT = NULL,
    @Title NVARCHAR(255),
    @Description NVARCHAR(MAX) = NULL,
    @Status NVARCHAR(50) = 'Pending',
    @Priority NVARCHAR(50) = 'Medium',
    @DueDate DATETIME = NULL,
    @Notes NVARCHAR(MAX) = NULL,
    @CreatedBy INT,
    @UpdatedBy INT = NULL,
    @AssignedTo INT = NULL,
    @AssignedAt DATETIME = NULL,
    @CompletedBy INT = NULL,
    @CompletedAt DATETIME = NULL,
    @DeletedBy INT = NULL,
    @IsDeleted BIT = 0,
    @DeletedAt DATETIME = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO DailyTask (BookingID, Title, Description, Status, Priority, DueDate, Notes, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, AssignedTo, AssignedAt, CompletedBy, CompletedAt, DeletedBy, DeletedAt, IsDeleted)
        VALUES (@BookingId, @Title, @Description, @Status, @Priority, @DueDate, @Notes, @CreatedBy, GETUTCDATE(), @UpdatedBy, GETUTCDATE(), @AssignedTo, @AssignedAt, @CompletedBy, @CompletedAt, @DeletedBy, @DeletedAt, @IsDeleted);
    ELSE
        UPDATE DailyTask
        SET BookingID = @BookingId, Title = @Title, Description = @Description, Status = @Status, Priority = @Priority,
            DueDate = @DueDate, Notes = @Notes, UpdatedBy = @UpdatedBy, UpdatedAt = GETUTCDATE(),
            AssignedTo = @AssignedTo, AssignedAt = @AssignedAt, CompletedBy = @CompletedBy, CompletedAt = @CompletedAt,
            DeletedBy = @DeletedBy, DeletedAt = @DeletedAt, IsDeleted = @IsDeleted
        WHERE TaskID = @Id AND IsDeleted = 0;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_DailyTask_GetById
    @Id INT
AS
BEGIN
    SELECT TaskID, BookingID, Title, Description, Status, Priority, DueDate, Notes,
           CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, AssignedTo, AssignedAt, CompletedBy, CompletedAt,
           DeletedBy, DeletedAt, IsDeleted
    FROM DailyTask WHERE TaskID = @Id AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_DailyTask_GetByStatus
    @Status NVARCHAR(50)
AS
BEGIN
    SELECT TaskID, BookingID, Title, Description, Status, Priority, DueDate, Notes,
           CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, AssignedTo, AssignedAt, CompletedBy, CompletedAt,
           DeletedBy, DeletedAt, IsDeleted
    FROM DailyTask WHERE Status = @Status AND IsDeleted = 0
    ORDER BY Priority DESC, DueDate ASC;
END;

CREATE PROCEDURE usp_DailyTask_GetByDate
    @Date DATETIME
AS
BEGIN
    SELECT TaskID, BookingID, Title, Description, Status, Priority, DueDate, Notes,
           CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, AssignedTo, AssignedAt, CompletedBy, CompletedAt,
           DeletedBy, DeletedAt, IsDeleted
    FROM DailyTask
    WHERE CAST(DueDate AS DATE) = CAST(@Date AS DATE) AND IsDeleted = 0
    ORDER BY DueDate;
END;

CREATE PROCEDURE usp_DailyTask_GetPaged
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SELECT TaskID, BookingID, Title, Description, Status, Priority, DueDate, Notes,
           CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, AssignedTo, AssignedAt, CompletedBy, CompletedAt,
           DeletedBy, DeletedAt, IsDeleted
    FROM DailyTask
    WHERE IsDeleted = 0
    ORDER BY DueDate DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    SELECT COUNT(*) AS TotalCount FROM DailyTask WHERE IsDeleted = 0;
END;

CREATE PROCEDURE usp_DailyTask_Delete
    @Id INT,
    @DeletedBy INT
AS
BEGIN
    UPDATE DailyTask
    SET IsDeleted = 1, DeletedBy = @DeletedBy, DeletedAt = GETUTCDATE()
    WHERE TaskID = @Id AND IsDeleted = 0;
END;

-- ============================================
-- TASK COMMENT PROCEDURES
-- ============================================

CREATE PROCEDURE usp_TaskComment_Upsert
    @Id INT = 0,
    @TaskId INT,
    @Comment NVARCHAR(MAX),
    @CreatedBy INT,
    @UpdatedBy INT = NULL,
    @IsDeleted BIT = 0,
    @DeletedAt DATETIME = NULL,
    @DeletedBy INT = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO TaskComment (TaskID, Comment, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, IsDeleted, DeletedAt, DeletedBy)
        VALUES (@TaskId, @Comment, @CreatedBy, GETUTCDATE(), @UpdatedBy, GETUTCDATE(), @IsDeleted, @DeletedAt, @DeletedBy);
    ELSE
        UPDATE TaskComment
        SET Comment = @Comment, UpdatedBy = @UpdatedBy, UpdatedAt = GETUTCDATE(),
            IsDeleted = @IsDeleted, DeletedAt = @DeletedAt, DeletedBy = @DeletedBy
        WHERE CommentID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_TaskComment_GetById
    @Id INT
AS
BEGIN
    SELECT CommentID, TaskID, Comment, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM TaskComment WHERE CommentID = @Id AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_TaskComment_GetByTask
    @TaskId INT
AS
BEGIN
    SELECT CommentID, TaskID, Comment, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM TaskComment WHERE TaskID = @TaskId AND IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE PROCEDURE usp_TaskComment_Delete
    @Id INT
AS
BEGIN
    DELETE FROM TaskComment WHERE CommentID = @Id;
END;

-- ============================================
-- BOOKING LOG PROCEDURES
-- ============================================

CREATE PROCEDURE usp_BookingLog_Upsert
    @BookingId INT,
    @Action NVARCHAR(100),
    @CreatedBy INT = NULL,
    @IsDeleted BIT = 0,
    @DeletedAt DATETIME = NULL,
    @DeletedBy INT = NULL
AS
BEGIN
    INSERT INTO BookingLog (BookingID, Action, Timestamp, CreatedBy, IsDeleted, DeletedAt, DeletedBy)
    VALUES (@BookingId, @Action, GETUTCDATE(), @CreatedBy, @IsDeleted, @DeletedAt, @DeletedBy);

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_BookingLog_GetByBooking
    @BookingId INT
AS
BEGIN
    SELECT LogID, BookingID, Action, Timestamp, CreatedBy, DeletedBy, DeletedAt, IsDeleted
    FROM BookingLog WHERE BookingID = @BookingId AND IsDeleted = 0
    ORDER BY Timestamp DESC;
END;

-- ============================================
-- VIEW ANALYTICS PROCEDURES
-- ============================================

CREATE PROCEDURE usp_ViewAnalytics_Increment
    @EntityType NVARCHAR(100),
    @EntityId INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM ViewAnalytics WHERE EntityType = @EntityType AND EntityID = @EntityId)
        UPDATE ViewAnalytics
        SET ViewCount = ViewCount + 1, LastViewedAt = GETUTCDATE(), UpdatedAt = GETUTCDATE()
        WHERE EntityType = @EntityType AND EntityID = @EntityId;
    ELSE
        INSERT INTO ViewAnalytics (EntityType, EntityID, ViewCount, LastViewedAt, UpdatedAt)
        VALUES (@EntityType, @EntityId, 1, GETUTCDATE(), GETUTCDATE());

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_ViewAnalytics_GetByEntity
    @EntityType NVARCHAR(100),
    @EntityId INT
AS
BEGIN
    SELECT AnalyticsID, EntityType, EntityID, ViewCount, LastViewedAt, UpdatedAt
    FROM ViewAnalytics WHERE EntityType = @EntityType AND EntityID = @EntityId;
END;

CREATE PROCEDURE usp_ViewAnalytics_GetTop
    @EntityType NVARCHAR(100),
    @TopCount INT = 10
AS
BEGIN
    SELECT TOP (@TopCount) AnalyticsID, EntityType, EntityID, ViewCount, LastViewedAt, UpdatedAt
    FROM ViewAnalytics WHERE EntityType = @EntityType
    ORDER BY ViewCount DESC;
END;

-- ============================================
-- INVOICE PROCEDURES
-- ============================================

CREATE PROCEDURE usp_Invoice_Upsert
    @Id INT = 0,
    @ClientID INT,
    @BookingId INT,
    @QuotationId INT = NULL,
    @InvoiceNumber NVARCHAR(50),
    @Amount DECIMAL(10,2),
    @TaxAmount DECIMAL(10,2) = 0,
    @TotalAmount DECIMAL(10,2),
    @Status NVARCHAR(50) = 'Draft',
    @IssuedDate DATETIME = NULL,
    @DueDate DATETIME = NULL,
    @PaidDate DATETIME = NULL,
    @PdfFileUrl NVARCHAR(500) = NULL,
    @CreatedBy INT,
    @UpdatedBy INT = NULL,
    @IsDeleted BIT = 0,
    @DeletedAt DATETIME = NULL,
    @DeletedBy INT = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO Invoice (ClientID, BookingID, QuotationID, InvoiceNumber, Amount, TaxAmount, TotalAmount, Status, IssuedDate, DueDate, PaidDate, PdfFileUrl, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, IsDeleted, DeletedAt, DeletedBy)
        VALUES (@ClientID, @BookingId, @QuotationId, @InvoiceNumber, @Amount, @TaxAmount, @TotalAmount, @Status, @IssuedDate, @DueDate, @PaidDate, @PdfFileUrl, @CreatedBy, GETUTCDATE(), @UpdatedBy, GETUTCDATE(), @IsDeleted, @DeletedAt, @DeletedBy);
    ELSE
        UPDATE Invoice
        SET ClientID = @ClientID, BookingID = @BookingId, QuotationID = @QuotationId, InvoiceNumber = @InvoiceNumber, Amount = @Amount, TaxAmount = @TaxAmount, TotalAmount = @TotalAmount,
            Status = @Status, IssuedDate = @IssuedDate, DueDate = @DueDate, PaidDate = @PaidDate, PdfFileUrl = @PdfFileUrl, UpdatedBy = @UpdatedBy, UpdatedAt = GETUTCDATE(),
            IsDeleted = @IsDeleted, DeletedAt = @DeletedAt, DeletedBy = @DeletedBy
        WHERE InvoiceID = @Id AND IsDeleted = 0;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_Invoice_GetById
    @Id INT
AS
BEGIN
    SELECT InvoiceID, ClientID, BookingID, QuotationID, InvoiceNumber, Amount, TaxAmount, TotalAmount, Status, IssuedDate, DueDate, PaidDate, PdfFileUrl, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM Invoice WHERE InvoiceID = @Id AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_Invoice_GetByBooking
    @BookingId INT
AS
BEGIN
    SELECT InvoiceID, ClientID, BookingID, QuotationID, InvoiceNumber, Amount, TaxAmount, TotalAmount, Status, IssuedDate, DueDate, PaidDate, PdfFileUrl, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM Invoice WHERE BookingID = @BookingId AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_Invoice_GetByClient
    @ClientID INT
AS
BEGIN
    SELECT InvoiceID, ClientID, BookingID, QuotationID, InvoiceNumber, Amount, TaxAmount, TotalAmount, Status, IssuedDate, DueDate, PaidDate, PdfFileUrl, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM Invoice WHERE ClientID = @ClientID AND IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

-- ============================================
-- SEO METADATA PROCEDURES
-- ============================================

CREATE PROCEDURE usp_SEOMetadata_Upsert
    @Id INT = 0,
    @PageType NVARCHAR(100),
    @PageId INT = NULL,
    @PageTitle NVARCHAR(255) = NULL,
    @MetaDescription NVARCHAR(500) = NULL,
    @MetaKeywords NVARCHAR(MAX) = NULL,
    @Slug NVARCHAR(255) = NULL,
    @CanonicalUrl NVARCHAR(500) = NULL,
    @OGTitle NVARCHAR(255) = NULL,
    @OGDescription NVARCHAR(500) = NULL,
    @OGImageUrl NVARCHAR(500) = NULL,
    @SchemaMarkup NVARCHAR(MAX) = NULL,
    @IsIndexed BIT = 1,
    @CreatedBy INT = NULL,
    @UpdatedBy INT = NULL,
    @IsDeleted BIT = 0,
    @DeletedAt DATETIME = NULL,
    @DeletedBy INT = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO SEOMetadata (PageType, PageID, PageTitle, MetaDescription, MetaKeywords, Slug, CanonicalUrl,
                                OGTitle, OGDescription, OGImageUrl, SchemaMarkup, IsIndexed, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt,
                                IsDeleted, DeletedAt, DeletedBy)
        VALUES (@PageType, @PageId, @PageTitle, @MetaDescription, @MetaKeywords, @Slug, @CanonicalUrl,
                @OGTitle, @OGDescription, @OGImageUrl, @SchemaMarkup, @IsIndexed, @CreatedBy, GETUTCDATE(), @UpdatedBy, GETUTCDATE(),
                @IsDeleted, @DeletedAt, @DeletedBy);
    ELSE
        UPDATE SEOMetadata
        SET PageType = @PageType, PageID = @PageId, PageTitle = @PageTitle, MetaDescription = @MetaDescription,
            MetaKeywords = @MetaKeywords, Slug = @Slug, CanonicalUrl = @CanonicalUrl, OGTitle = @OGTitle,
            OGDescription = @OGDescription, OGImageUrl = @OGImageUrl, SchemaMarkup = @SchemaMarkup,
            IsIndexed = @IsIndexed, UpdatedBy = @UpdatedBy, UpdatedAt = GETUTCDATE(),
            IsDeleted = @IsDeleted, DeletedAt = @DeletedAt, DeletedBy = @DeletedBy
        WHERE MetadataID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_SEOMetadata_GetById
    @Id INT
AS
BEGIN
    SELECT MetadataID, PageType, PageID, PageTitle, MetaDescription, MetaKeywords, Slug, CanonicalUrl,
           OGTitle, OGDescription, OGImageUrl, SchemaMarkup, IsIndexed, CreatedAt, UpdatedAt, CreatedBy, UpdatedBy, DeletedBy, DeletedAt, IsDeleted
    FROM SEOMetadata WHERE MetadataID = @Id AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_SEOMetadata_GetBySlug
    @Slug NVARCHAR(255)
AS
BEGIN
    SELECT MetadataID, PageType, PageID, PageTitle, MetaDescription, MetaKeywords, Slug, CanonicalUrl,
           OGTitle, OGDescription, OGImageUrl, SchemaMarkup, IsIndexed, CreatedAt, UpdatedAt, CreatedBy, UpdatedBy, DeletedBy, DeletedAt, IsDeleted
    FROM SEOMetadata WHERE Slug = @Slug AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_SEOMetadata_GetByPageTypeAndId
    @PageType NVARCHAR(100),
    @PageId INT
AS
BEGIN
    SELECT MetadataID, PageType, PageID, PageTitle, MetaDescription, MetaKeywords, Slug, CanonicalUrl,
           OGTitle, OGDescription, OGImageUrl, SchemaMarkup, IsIndexed, CreatedAt, UpdatedAt, CreatedBy, UpdatedBy, DeletedBy, DeletedAt, IsDeleted
    FROM SEOMetadata WHERE PageType = @PageType AND PageID = @PageId AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_SEOMetadata_Delete
    @Id INT
AS
BEGIN
    DELETE FROM SEOMetadata WHERE MetadataID = @Id;
END;

-- ============================================
-- SETTINGS PROCEDURES
-- ============================================

CREATE PROCEDURE usp_Settings_Upsert
    @SettingKey NVARCHAR(100),
    @SettingValue NVARCHAR(MAX)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Settings WHERE SettingKey = @SettingKey)
        UPDATE Settings
        SET SettingValue = @SettingValue, UpdatedAt = GETUTCDATE()
        WHERE SettingKey = @SettingKey;
    ELSE
        INSERT INTO Settings (SettingKey, SettingValue, UpdatedAt)
        VALUES (@SettingKey, @SettingValue, GETUTCDATE());

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_Settings_GetByKey
    @SettingKey NVARCHAR(100)
AS
BEGIN
    SELECT SettingID, SettingKey, SettingValue, UpdatedAt
    FROM Settings WHERE SettingKey = @SettingKey;
END;

CREATE PROCEDURE usp_Settings_GetAll
AS
BEGIN
    SELECT SettingID, SettingKey, SettingValue, UpdatedAt
    FROM Settings;
END;

-- ============================================
-- EVENT PROCEDURES
-- ============================================

CREATE PROCEDURE usp_Event_Upsert
    @Id INT = 0,
    @EventName NVARCHAR(255),
    @EventDate DATETIME,
    @Location NVARCHAR(500) = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @CreatedBy INT,
    @UpdatedBy INT = NULL,
    @Status NVARCHAR(50) = 'Scheduled',
    @EventType NVARCHAR(100) = NULL,
    @IsDeleted BIT = 0,
    @DeletedAt DATETIME = NULL,
    @DeletedBy INT = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO Event (EventName, EventDate, Location, Description, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, Status, IsDeleted, EventType, DeletedAt, DeletedBy)
        VALUES (@EventName, @EventDate, @Location, @Description, @CreatedBy, GETUTCDATE(), @UpdatedBy, GETUTCDATE(), @Status, @IsDeleted, @EventType, @DeletedAt, @DeletedBy);
    ELSE
        UPDATE Event
        SET EventName = @EventName, EventDate = @EventDate, Location = @Location, Description = @Description,
            Status = @Status, UpdatedBy = @UpdatedBy, UpdatedAt = GETUTCDATE(), EventType = @EventType,
            IsDeleted = @IsDeleted, DeletedAt = @DeletedAt, DeletedBy = @DeletedBy
        WHERE EventID = @Id AND IsDeleted = 0;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_Event_GetById
    @Id INT
AS
BEGIN
    SELECT EventID, EventName, EventDate, Location, Description, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, Status, IsDeleted, EventType
    FROM Event WHERE EventID = @Id AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_Event_GetByType
    @EventType NVARCHAR(100)
AS
BEGIN
    SELECT EventID, EventName, EventDate, Location, Description, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, Status, EventType, IsDeleted
    FROM Event
    WHERE EventType = @EventType AND IsDeleted = 0
    ORDER BY EventDate DESC;
END;

CREATE PROCEDURE usp_Event_GetByUserId
    @UserId INT
AS
BEGIN
    SELECT EventID, EventName, EventDate, Location, Description, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, Status, IsDeleted
    FROM Event WHERE CreatedBy = @UserId AND IsDeleted = 0
    ORDER BY EventDate DESC;
END;

CREATE PROCEDURE usp_Event_GetPaged
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SELECT EventID, EventName, EventDate, Location, Description, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, Status, IsDeleted
    FROM Event
    WHERE IsDeleted = 0
    ORDER BY EventDate DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    SELECT COUNT(*) AS TotalCount FROM Event WHERE IsDeleted = 0;
END;

CREATE PROCEDURE usp_Event_Delete
    @Id INT,
    @DeletedBy INT
AS
BEGIN
    UPDATE Event
    SET IsDeleted = 1, DeletedBy = @DeletedBy, DeletedAt = GETUTCDATE()
    WHERE EventID = @Id AND IsDeleted = 0;
END;

-- ============================================
-- EVENT INVITATION PROCEDURES
-- ============================================

-- ============================================
-- QUOTATION PROCEDURES
-- ============================================

CREATE PROCEDURE usp_Quotation_Upsert
    @Id INT = 0,
    @EventId INT,
    @ClientEmail NVARCHAR(255),
    @ClientName NVARCHAR(255) = NULL,
    @QuotationNumber NVARCHAR(50),
    @ValidUntil DATETIME = NULL,
    @SubTotal DECIMAL(10,2) = NULL,
    @TaxAmount DECIMAL(10,2) = 0,
    @TotalAmount DECIMAL(10,2),
    @Status NVARCHAR(50) = 'Draft',
    @Notes NVARCHAR(MAX) = NULL,
    @CreatedBy INT,
    @UpdatedBy INT = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO Quotation (EventID, ClientEmail, ClientName, QuotationNumber, QuotationDate, ValidUntil, SubTotal, TaxAmount, TotalAmount, Status, Notes, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, IsDeleted)
        VALUES (@EventId, @ClientEmail, @ClientName, @QuotationNumber, GETUTCDATE(), @ValidUntil, @SubTotal, @TaxAmount, @TotalAmount, @Status, @Notes, @CreatedBy, GETUTCDATE(), @UpdatedBy, GETUTCDATE(), 0);
    ELSE
        UPDATE Quotation
        SET EventID = @EventId, ClientEmail = @ClientEmail, ClientName = @ClientName, ValidUntil = @ValidUntil, SubTotal = @SubTotal,
            TaxAmount = @TaxAmount, TotalAmount = @TotalAmount, Status = @Status, Notes = @Notes, UpdatedBy = @UpdatedBy, UpdatedAt = GETUTCDATE()
        WHERE QuotationID = @Id AND IsDeleted = 0;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_Quotation_GetById
    @Id INT
AS
BEGIN
    SELECT QuotationID, EventID, ClientEmail, ClientName, QuotationNumber, QuotationDate, ValidUntil, SubTotal, TaxAmount,
           TotalAmount, Status, Notes, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM Quotation WHERE QuotationID = @Id AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_Quotation_GetByEvent
    @EventId INT
AS
BEGIN
    SELECT QuotationID, EventID, ClientEmail, ClientName, QuotationNumber, QuotationDate, ValidUntil, SubTotal, TaxAmount,
           TotalAmount, Status, Notes, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM Quotation WHERE EventID = @EventId AND IsDeleted = 0
    ORDER BY QuotationDate DESC;
END;

CREATE PROCEDURE usp_Quotation_GetByClientEmail
    @ClientEmail NVARCHAR(255)
AS
BEGIN
    SELECT QuotationID, EventID, ClientEmail, ClientName, QuotationNumber, QuotationDate, ValidUntil, SubTotal, TaxAmount,
           TotalAmount, Status, Notes, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM Quotation WHERE ClientEmail = @ClientEmail AND IsDeleted = 0
    ORDER BY QuotationDate DESC;
END;

CREATE PROCEDURE usp_Quotation_GetPaged
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SELECT QuotationID, EventID, ClientEmail, ClientName, QuotationNumber, QuotationDate, ValidUntil, SubTotal, TaxAmount,
           TotalAmount, Status, Notes, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM Quotation
    WHERE IsDeleted = 0
    ORDER BY QuotationDate DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    SELECT COUNT(*) AS TotalCount FROM Quotation WHERE IsDeleted = 0;
END;

CREATE PROCEDURE usp_Quotation_Delete
    @Id INT
AS
BEGIN
    UPDATE Quotation
    SET IsDeleted = 1, DeletedAt = GETUTCDATE(), UpdatedAt = GETUTCDATE()
    WHERE QuotationID = @Id;
END;

-- ============================================
-- QUOTATION ITEM PROCEDURES
-- ============================================

CREATE PROCEDURE usp_QuotationItem_Upsert
    @Id INT = 0,
    @QuotationId INT,
    @ItemDescription NVARCHAR(MAX),
    @Quantity INT = 1,
    @UnitPrice DECIMAL(10,2),
    @Amount DECIMAL(10,2),
    @DisplayOrder INT = 0
AS
BEGIN
    IF @Id = 0
        INSERT INTO QuotationItem (QuotationID, ItemDescription, Quantity, UnitPrice, Amount, DisplayOrder, CreatedAt)
        VALUES (@QuotationId, @ItemDescription, @Quantity, @UnitPrice, @Amount, @DisplayOrder, GETUTCDATE());
    ELSE
        UPDATE QuotationItem
        SET ItemDescription = @ItemDescription, Quantity = @Quantity, UnitPrice = @UnitPrice, Amount = @Amount, DisplayOrder = @DisplayOrder
        WHERE ItemID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_QuotationItem_GetByQuotation
    @QuotationId INT
AS
BEGIN
    SELECT ItemID, QuotationID, ItemDescription, Quantity, UnitPrice, Amount, DisplayOrder, CreatedAt
    FROM QuotationItem WHERE QuotationID = @QuotationId
    ORDER BY DisplayOrder;
END;

CREATE PROCEDURE usp_QuotationItem_Delete
    @Id INT
AS
BEGIN
    DELETE FROM QuotationItem WHERE ItemID = @Id;
END;

-- ============================================
-- QUOTATION TO BOOKING CONVERSION
-- ============================================

CREATE PROCEDURE usp_Quotation_ConvertToBooking
    @QuotationId INT,
    @PackageId INT,
    @ClientId INT,
    @BookingDate DATETIME,
    @Location NVARCHAR(500) = NULL,
    @SpecialRequests NVARCHAR(MAX) = NULL
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Get quotation and event details
        DECLARE @EventId INT, @TotalAmount DECIMAL(10,2), @PhotographerUserId INT;
        SELECT @EventId = q.EventID, @TotalAmount = q.TotalAmount, @PhotographerUserId = e.CreatedByUserID
        FROM Quotation q
        INNER JOIN Event e ON q.EventID = e.EventID
        WHERE q.QuotationID = @QuotationId AND q.IsDeleted = 0 AND q.Status = 'Accepted';

        IF @EventId IS NULL
            THROW 50001, 'Quotation not found or not in Accepted status', 1;

        -- Create Booking
        INSERT INTO Booking (PackageID, ClientID, QuotationID, PhotographerUserID, BookingDate, Location, Status, TotalPrice, SpecialRequests, IsDeleted, CreatedAt, UpdatedAt)
        VALUES (@PackageId, @ClientId, @QuotationId, @PhotographerUserId, @BookingDate, @Location, 'Confirmed', @TotalAmount, @SpecialRequests, 0, GETUTCDATE(), GETUTCDATE());

        DECLARE @BookingId INT = @@IDENTITY;

        -- Create BookingPackage with snapshot
        DECLARE @QuotationSnapshot NVARCHAR(MAX);
        SELECT @QuotationSnapshot = (
            SELECT QuotationNumber, TotalAmount, (
                SELECT ItemID, ItemDescription, Quantity, UnitPrice, Amount
                FROM QuotationItem
                WHERE QuotationID = @QuotationId
                FOR JSON PATH
            ) AS Items
            FROM Quotation
            WHERE QuotationID = @QuotationId
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        INSERT INTO BookingPackage (BookingID, PackageID, AppliedDiscount, FinalPrice, PackageSnapshot, CreatedAt)
        VALUES (@BookingId, @PackageId, 0, @TotalAmount, @QuotationSnapshot, GETUTCDATE());

        -- Link booking to event gallery
        INSERT INTO BookingGallery (BookingID, GalleryID, IsDeliveryGallery, AvailableFrom, AvailableUntil, CreatedAt)
        SELECT TOP 1 @BookingId, g.GalleryID, 1, DATEADD(DAY, 1, @BookingDate), DATEADD(DAY, 30, @BookingDate), GETUTCDATE()
        FROM Gallery g
        WHERE g.EventID = @EventId AND g.IsPrivate = 1
        ORDER BY g.GalleryID;

        -- Create calendar block for booking
        INSERT INTO CalendarBlock (BookingID, BlockStart, BlockEnd, Status, BlockReason, CreatedAt)
        VALUES (@BookingId, @BookingDate, DATEADD(DAY, 1, @BookingDate), 'Booked', 'Event Booking', GETUTCDATE());

        -- Update quotation status
        UPDATE Quotation
        SET Status = 'Converted', UpdatedAt = GETUTCDATE()
        WHERE QuotationID = @QuotationId;

        -- Log change
        INSERT INTO ChangeLog (EntityType, EntityID, FieldName, OldValue, NewValue, ChangeType, Reason, CreatedAt)
        VALUES ('Quotation', @QuotationId, 'Status', 'Accepted', 'Converted', 'ConvertToBooking', 'Converted to Booking #' + CAST(@BookingId AS NVARCHAR), GETUTCDATE());

        COMMIT TRANSACTION;

        SELECT @BookingId AS BookingID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;

-- ============================================
-- TAG PROCEDURES
-- ============================================

CREATE PROCEDURE usp_Tag_Upsert
    @Id INT = 0,
    @TagName NVARCHAR(100),
    @TagType NVARCHAR(50),
    @CreatedByUserId INT = NULL
AS
BEGIN
    IF @Id = 0
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Tag WHERE TagName = @TagName AND TagType = @TagType)
            INSERT INTO Tag (TagName, TagType, CreatedByUserID, CreatedAt)
            VALUES (@TagName, @TagType, @CreatedByUserId, GETUTCDATE());
    END
    ELSE
    BEGIN
        UPDATE Tag
        SET TagName = @TagName, TagType = @TagType
        WHERE TagID = @Id;
    END

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_Tag_GetByType
    @TagType NVARCHAR(50)
AS
BEGIN
    SELECT TagID, TagName, TagType, CreatedByUserID, CreatedAt
    FROM Tag WHERE TagType = @TagType
    ORDER BY TagName;
END;

CREATE PROCEDURE usp_Tag_GetAll
AS
BEGIN
    SELECT TagID, TagName, TagType, CreatedByUserID, CreatedAt
    FROM Tag
    ORDER BY TagType, TagName;
END;

CREATE PROCEDURE usp_Tag_Delete
    @Id INT
AS
BEGIN
    DELETE FROM EntityTag WHERE TagID = @Id;
    DELETE FROM Tag WHERE TagID = @Id;
END;

-- ============================================
-- ENTITY TAG PROCEDURES
-- ============================================

CREATE PROCEDURE usp_EntityTag_Assign
    @TagId INT,
    @EntityType NVARCHAR(50),
    @EntityId INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM EntityTag WHERE TagID = @TagId AND EntityType = @EntityType AND EntityID = @EntityId)
        INSERT INTO EntityTag (TagID, EntityType, EntityID, AssignedAt)
        VALUES (@TagId, @EntityType, @EntityId, GETUTCDATE());

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_EntityTag_Remove
    @TagId INT,
    @EntityType NVARCHAR(50),
    @EntityId INT
AS
BEGIN
    DELETE FROM EntityTag WHERE TagID = @TagId AND EntityType = @EntityType AND EntityID = @EntityId;
END;

CREATE PROCEDURE usp_EntityTag_GetByEntity
    @EntityType NVARCHAR(50),
    @EntityId INT
AS
BEGIN
    SELECT t.TagID, t.TagName, t.TagType, et.AssignedAt
    FROM EntityTag et
    INNER JOIN Tag t ON et.TagID = t.TagID
    WHERE et.EntityType = @EntityType AND et.EntityID = @EntityId
    ORDER BY t.TagName;
END;

-- ============================================
-- PAYMENT PROCEDURES
-- ============================================

CREATE PROCEDURE usp_Payment_Upsert
    @Id INT = 0,
    @InvoiceId INT,
    @BookingId INT = NULL,
    @Amount DECIMAL(10,2),
    @Status NVARCHAR(50) = 'Pending',
    @PaymentMethodID INT = NULL,
    @TransactionId NVARCHAR(255) = NULL,
    @ProcessedAt DATETIME = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO Payment (InvoiceID, BookingID, Amount, Status, PaymentMethodID, TransactionID, ProcessedAt, CreatedAt, UpdatedAt)
        VALUES (@InvoiceId, @BookingId, @Amount, @Status, @PaymentMethodID, @TransactionId, @ProcessedAt, GETUTCDATE(), GETUTCDATE());
    ELSE
        UPDATE Payment
        SET InvoiceID = @InvoiceId, BookingID = @BookingId, Amount = @Amount, Status = @Status,
            PaymentMethodID = @PaymentMethodID, TransactionID = @TransactionId, ProcessedAt = @ProcessedAt, UpdatedAt = GETUTCDATE()
        WHERE PaymentID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_Payment_GetById
    @PaymentID INT
AS
BEGIN
    SELECT p.PaymentID, p.InvoiceID, p.BookingID, p.Amount, p.Status, p.PaymentMethodID, pm.MethodName, p.TransactionID, p.ProcessedAt, p.CreatedAt, p.UpdatedAt
    FROM Payment p
    LEFT JOIN PaymentMethod pm ON p.PaymentMethodID = pm.PaymentMethodID
    WHERE p.PaymentID = @PaymentID;
END;

CREATE PROCEDURE usp_Payment_GetByInvoice
    @InvoiceId INT
AS
BEGIN
    SELECT p.PaymentID, p.InvoiceID, p.BookingID, p.Amount, p.Status, p.PaymentMethodID, pm.MethodName, p.TransactionID, p.ProcessedAt, p.CreatedAt, p.UpdatedAt
    FROM Payment p
    LEFT JOIN PaymentMethod pm ON p.PaymentMethodID = pm.PaymentMethodID
    WHERE p.InvoiceID = @InvoiceId
    ORDER BY p.CreatedAt DESC;
END;

CREATE PROCEDURE usp_Payment_GetByBooking
    @BookingId INT
AS
BEGIN
    SELECT p.PaymentID, p.InvoiceID, p.BookingID, p.Amount, p.Status, p.PaymentMethodID, pm.MethodName, p.TransactionID, p.ProcessedAt, p.CreatedAt, p.UpdatedAt
    FROM Payment p
    LEFT JOIN PaymentMethod pm ON p.PaymentMethodID = pm.PaymentMethodID
    WHERE p.BookingID = @BookingId
    ORDER BY p.CreatedAt DESC;
END;

CREATE PROCEDURE usp_Payment_GetByStatus
    @Status NVARCHAR(50)
AS
BEGIN
    SELECT p.PaymentID, p.InvoiceID, p.BookingID, p.Amount, p.Status, p.PaymentMethodID, pm.MethodName, p.TransactionID, p.ProcessedAt, p.CreatedAt, p.UpdatedAt
    FROM Payment p
    LEFT JOIN PaymentMethod pm ON p.PaymentMethodID = pm.PaymentMethodID
    WHERE p.Status = @Status
    ORDER BY p.CreatedAt DESC;
END;

CREATE PROCEDURE usp_Payment_GetByMethod
    @PaymentMethodID INT
AS
BEGIN
    SELECT p.PaymentID, p.InvoiceID, p.BookingID, p.Amount, p.Status, p.PaymentMethodID, pm.MethodName, p.TransactionID, p.ProcessedAt, p.CreatedAt, p.UpdatedAt
    FROM Payment p
    LEFT JOIN PaymentMethod pm ON p.PaymentMethodID = pm.PaymentMethodID
    WHERE p.PaymentMethodID = @PaymentMethodID
    ORDER BY p.CreatedAt DESC;
END;

-- ============================================
-- BOOKING GALLERY PROCEDURES
-- ============================================

CREATE PROCEDURE usp_BookingGallery_Link
    @BookingId INT,
    @GalleryId INT,
    @IsDeliveryGallery BIT = 1,
    @AvailableFrom DATETIME = NULL,
    @AvailableUntil DATETIME = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM BookingGallery WHERE BookingID = @BookingId AND GalleryID = @GalleryId)
        INSERT INTO BookingGallery (BookingID, GalleryID, IsDeliveryGallery, AvailableFrom, AvailableUntil, CreatedAt)
        VALUES (@BookingId, @GalleryId, @IsDeliveryGallery, @AvailableFrom, @AvailableUntil, GETUTCDATE());

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_BookingGallery_GetByBooking
    @BookingId INT
AS
BEGIN
    SELECT bg.BookingGalleryID, bg.BookingID, bg.GalleryID, g.Title, g.Description, bg.IsDeliveryGallery,
           bg.AvailableFrom, bg.AvailableUntil, bg.CreatedAt
    FROM BookingGallery bg
    INNER JOIN Gallery g ON bg.GalleryID = g.GalleryID
    WHERE bg.BookingID = @BookingId;
END;

CREATE PROCEDURE usp_BookingGallery_Unlink
    @BookingId INT,
    @GalleryId INT
AS
BEGIN
    DELETE FROM BookingGallery WHERE BookingID = @BookingId AND GalleryID = @GalleryId;
END;

-- ============================================
-- CHANGE LOG PROCEDURES
-- ============================================

CREATE PROCEDURE usp_ChangeLog_Record
    @EntityType NVARCHAR(100),
    @EntityId INT,
    @FieldName NVARCHAR(100) = NULL,
    @OldValue NVARCHAR(MAX) = NULL,
    @NewValue NVARCHAR(MAX) = NULL,
    @ChangeType NVARCHAR(50) = 'Update',
    @ChangedByUserId INT = NULL,
    @Reason NVARCHAR(MAX) = NULL
AS
BEGIN
    INSERT INTO ChangeLog (EntityType, EntityID, FieldName, OldValue, NewValue, ChangeType, ChangedByUserID, Reason, CreatedAt)
    VALUES (@EntityType, @EntityId, @FieldName, @OldValue, @NewValue, @ChangeType, @ChangedByUserId, @Reason, GETUTCDATE());

    SELECT @@IDENTITY AS ChangeLogID;
END;

CREATE PROCEDURE usp_ChangeLog_GetByEntity
    @EntityType NVARCHAR(100),
    @EntityId INT
AS
BEGIN
    SELECT ChangeLogID, EntityType, EntityID, FieldName, OldValue, NewValue, ChangeType, ChangedByUserID, Reason, CreatedAt
    FROM ChangeLog
    WHERE EntityType = @EntityType AND EntityID = @EntityId
    ORDER BY CreatedAt DESC;
END;

CREATE PROCEDURE usp_ChangeLog_GetByDateRange
    @StartDate DATETIME,
    @EndDate DATETIME
AS
BEGIN
    SELECT ChangeLogID, EntityType, EntityID, FieldName, OldValue, NewValue, ChangeType, ChangedByUserID, Reason, CreatedAt
    FROM ChangeLog
    WHERE CreatedAt BETWEEN @StartDate AND @EndDate
    ORDER BY CreatedAt DESC;
END;

-- ============================================
-- PRIVATE GALLERY PROCEDURES
-- ============================================

CREATE PROCEDURE usp_Gallery_GetPrivateByUser
    @UserId INT
AS
BEGIN
    SELECT g.GalleryID, g.GalleryTypeID, gt.TypeName, g.Title, g.Description, g.Category,
            g.ThumbnailUrl, g.DisplayOrder, g.IsFeatured, g.IsPublished, g.IsPrivate, g.ViewCount,
            g.RotationSpeed, g.StartDate, g.EndDate, g.CreatedBy, g.CreatedAt, g.UpdatedBy, g.UpdatedAt
    FROM Gallery g
    INNER JOIN GalleryType gt ON g.GalleryTypeID = gt.GalleryTypeID
    WHERE g.CreatedBy = @UserId AND g.IsPrivate = 1
    ORDER BY g.DisplayOrder, g.CreatedAt DESC;
END;

CREATE PROCEDURE usp_Gallery_GetAccessibleByUser
    @UserId INT
AS
BEGIN
    SELECT DISTINCT g.GalleryID, g.GalleryTypeID, gt.TypeName, g.Title, g.Description, g.Category,
            g.ThumbnailUrl, g.DisplayOrder, g.IsFeatured, g.IsPublished, g.IsPrivate, g.ViewCount,
            g.RotationSpeed, g.StartDate, g.EndDate, g.CreatedBy, g.CreatedAt, g.UpdatedBy, g.UpdatedAt
    FROM Gallery g
    INNER JOIN GalleryType gt ON g.GalleryTypeID = gt.GalleryTypeID
    LEFT JOIN GalleryAccess ga ON g.GalleryID = ga.GalleryID AND ga.UserID = @UserId
    WHERE (g.CreatedBy = @UserId) OR (ga.UserID = @UserId)
    ORDER BY g.DisplayOrder, g.CreatedAt DESC;
END;

CREATE PROCEDURE usp_Gallery_GetImagePickerData
    @UserId INT,
    @AssetType NVARCHAR(50) = 'Image'
AS
BEGIN
    SELECT ga.AssetID, g.GalleryID, g.Title AS GalleryTitle, ga.AssetType, ga.MediaUrl,
            ga.ThumbnailUrl, ga.Caption, ga.DisplayOrder
    FROM GalleryAsset ga
    INNER JOIN Gallery g ON ga.GalleryID = g.GalleryID
    LEFT JOIN GalleryAccess gac ON g.GalleryID = gac.GalleryID AND gac.UserID = @UserId
    WHERE (g.CreatedByUserID = @UserId OR gac.UserID = @UserId)
      AND ga.AssetType = @AssetType
    ORDER BY g.Title, ga.DisplayOrder;
END;

CREATE PROCEDURE usp_GalleryAccess_Grant
    @GalleryId INT,
    @UserId INT,
    @AccessLevel NVARCHAR(50) = 'View',
    @CreatedBy INT = NULL,
    @IsDeleted BIT = 0,
    @DeletedAt DATETIME = NULL,
    @DeletedBy INT = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM GalleryAccess WHERE GalleryID = @GalleryId AND UserID = @UserId)
        INSERT INTO GalleryAccess (GalleryID, UserID, AccessLevel, GrantedAt, CreatedBy, IsDeleted, DeletedAt, DeletedBy)
        VALUES (@GalleryId, @UserId, @AccessLevel, GETUTCDATE(), @CreatedBy, @IsDeleted, @DeletedAt, @DeletedBy);
    ELSE
        UPDATE GalleryAccess
        SET AccessLevel = @AccessLevel, IsDeleted = @IsDeleted, DeletedAt = @DeletedAt, DeletedBy = @DeletedBy
        WHERE GalleryID = @GalleryId AND UserID = @UserId;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_GalleryAccess_Revoke
    @GalleryId INT,
    @UserId INT,
    @DeletedBy INT
AS
BEGIN
    UPDATE GalleryAccess
    SET IsDeleted = 1, DeletedBy = @DeletedBy, DeletedAt = GETUTCDATE()
    WHERE GalleryID = @GalleryId AND UserID = @UserId AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_GalleryAccess_GetByGallery
    @GalleryId INT
AS
BEGIN
    SELECT ga.AccessID, ga.GalleryID, ga.UserID, u.FullName, u.Email, ga.AccessLevel, ga.GrantedAt, ga.DeletedBy, ga.DeletedAt, ga.IsDeleted
    FROM GalleryAccess ga
    INNER JOIN Users u ON ga.UserID = u.UserID
    WHERE ga.GalleryID = @GalleryId AND ga.IsDeleted = 0
    ORDER BY u.FullName;
END;

-- ============================================
-- ASSET PROCEDURES
-- ============================================

CREATE PROCEDURE usp_Asset_Upsert
    @Id INT = 0,
    @AssetType NVARCHAR(50),
    @EntityType NVARCHAR(100),
    @EntityID INT,
    @FilePath NVARCHAR(500),
    @FileName NVARCHAR(255),
    @FileSize BIGINT = NULL,
    @MimeType NVARCHAR(100) = NULL,
    @Description NVARCHAR(MAX) = NULL,
    @UploadedByUserID INT
AS
BEGIN
    IF @Id = 0
        INSERT INTO Asset (AssetType, EntityType, EntityID, FilePath, FileName, FileSize, MimeType, Description, UploadedByUserID, IsDeleted, CreatedAt, UpdatedAt)
        VALUES (@AssetType, @EntityType, @EntityID, @FilePath, @FileName, @FileSize, @MimeType, @Description, @UploadedByUserID, 0, GETUTCDATE(), GETUTCDATE());
    ELSE
        UPDATE Asset
        SET AssetType = @AssetType, EntityType = @EntityType, EntityID = @EntityID, FilePath = @FilePath, FileName = @FileName,
            FileSize = @FileSize, MimeType = @MimeType, Description = @Description, UpdatedAt = GETUTCDATE()
        WHERE AssetID = @Id AND IsDeleted = 0;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_Asset_GetById
    @Id INT
AS
BEGIN
    SELECT AssetID, AssetType, EntityType, EntityID, FilePath, FileName, FileSize, MimeType, Description, UploadedByUserID, IsDeleted, DeletedAt, CreatedAt, UpdatedAt
    FROM Asset WHERE AssetID = @Id AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_Asset_GetByEntity
    @EntityType NVARCHAR(100),
    @EntityID INT
AS
BEGIN
    SELECT AssetID, AssetType, EntityType, EntityID, FilePath, FileName, FileSize, MimeType, Description, UploadedByUserID, IsDeleted, DeletedAt, CreatedAt, UpdatedAt
    FROM Asset WHERE EntityType = @EntityType AND EntityID = @EntityID AND IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE PROCEDURE usp_Asset_GetByAssetType
    @AssetType NVARCHAR(50)
AS
BEGIN
    SELECT AssetID, AssetType, EntityType, EntityID, FilePath, FileName, FileSize, MimeType, Description, UploadedByUserID, IsDeleted, DeletedAt, CreatedAt, UpdatedAt
    FROM Asset WHERE AssetType = @AssetType AND IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE PROCEDURE usp_Asset_Delete
    @Id INT
AS
BEGIN
    UPDATE Asset
    SET IsDeleted = 1, DeletedAt = GETUTCDATE()
    WHERE AssetID = @Id AND IsDeleted = 0;
END;

-- ============================================
-- EXPENSE PROCEDURES
-- ============================================

CREATE PROCEDURE usp_Expense_Upsert
    @Id INT = 0,
    @BookingID INT = NULL,
    @EventID INT = NULL,
    @ExpenseType NVARCHAR(100),
    @Description NVARCHAR(MAX) = NULL,
    @Amount DECIMAL(10,2),
    @Currency NVARCHAR(10) = 'USD',
    @Status NVARCHAR(50) = 'Pending',
    @ReceiptAssetID INT = NULL,
    @CreatedByUserID INT,
    @ApprovedByUserID INT = NULL,
    @ApprovedDate DATETIME = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO Expense (BookingID, EventID, ExpenseType, Description, Amount, Currency, Status, ReceiptAssetID, CreatedByUserID, ApprovedByUserID, ApprovedDate, IsDeleted, CreatedAt, UpdatedAt)
        VALUES (@BookingID, @EventID, @ExpenseType, @Description, @Amount, @Currency, @Status, @ReceiptAssetID, @CreatedByUserID, @ApprovedByUserID, @ApprovedDate, 0, GETUTCDATE(), GETUTCDATE());
    ELSE
        UPDATE Expense
        SET BookingID = @BookingID, EventID = @EventID, ExpenseType = @ExpenseType, Description = @Description, Amount = @Amount, Currency = @Currency,
            Status = @Status, ReceiptAssetID = @ReceiptAssetID, ApprovedByUserID = @ApprovedByUserID, ApprovedDate = @ApprovedDate, UpdatedAt = GETUTCDATE()
        WHERE ExpenseID = @Id AND IsDeleted = 0;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_Expense_GetById
    @Id INT
AS
BEGIN
    SELECT ExpenseID, BookingID, EventID, ExpenseType, Description, Amount, Currency, Status, ReceiptAssetID, CreatedByUserID, ApprovedByUserID, ApprovedDate, IsDeleted, DeletedAt, CreatedAt, UpdatedAt
    FROM Expense WHERE ExpenseID = @Id AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_Expense_GetByBooking
    @BookingID INT
AS
BEGIN
    SELECT ExpenseID, BookingID, EventID, ExpenseType, Description, Amount, Currency, Status, ReceiptAssetID, CreatedByUserID, ApprovedByUserID, ApprovedDate, IsDeleted, DeletedAt, CreatedAt, UpdatedAt
    FROM Expense WHERE BookingID = @BookingID AND IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE PROCEDURE usp_Expense_GetByEvent
    @EventID INT
AS
BEGIN
    SELECT ExpenseID, BookingID, EventID, ExpenseType, Description, Amount, Currency, Status, ReceiptAssetID, CreatedByUserID, ApprovedByUserID, ApprovedDate, IsDeleted, DeletedAt, CreatedAt, UpdatedAt
    FROM Expense WHERE EventID = @EventID AND IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE PROCEDURE usp_Expense_GetByStatus
    @Status NVARCHAR(50)
AS
BEGIN
    SELECT ExpenseID, BookingID, EventID, ExpenseType, Description, Amount, Currency, Status, ReceiptAssetID, CreatedByUserID, ApprovedByUserID, ApprovedDate, IsDeleted, DeletedAt, CreatedAt, UpdatedAt
    FROM Expense WHERE Status = @Status AND IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE PROCEDURE usp_Expense_GetByExpenseType
    @ExpenseType NVARCHAR(100)
AS
BEGIN
    SELECT ExpenseID, BookingID, EventID, ExpenseType, Description, Amount, Currency, Status, ReceiptAssetID, CreatedByUserID, ApprovedByUserID, ApprovedDate, IsDeleted, DeletedAt, CreatedAt, UpdatedAt
    FROM Expense WHERE ExpenseType = @ExpenseType AND IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE PROCEDURE usp_Expense_GetAll
AS
BEGIN
    SELECT ExpenseID, BookingID, EventID, ExpenseType, Description, Amount, Currency, Status, ReceiptAssetID, CreatedByUserID, ApprovedByUserID, ApprovedDate, IsDeleted, DeletedAt, CreatedAt, UpdatedAt
    FROM Expense WHERE IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE PROCEDURE usp_Expense_ApproveExpense
    @ExpenseID INT,
    @ApprovedByUserID INT
AS
BEGIN
    UPDATE Expense
    SET Status = 'Approved', ApprovedByUserID = @ApprovedByUserID, ApprovedDate = GETUTCDATE(), UpdatedAt = GETUTCDATE()
    WHERE ExpenseID = @ExpenseID AND IsDeleted = 0 AND Status = 'Pending';
END;

CREATE PROCEDURE usp_Expense_RejectExpense
    @ExpenseID INT
AS
BEGIN
    UPDATE Expense
    SET Status = 'Rejected', UpdatedAt = GETUTCDATE()
    WHERE ExpenseID = @ExpenseID AND IsDeleted = 0 AND Status = 'Pending';
END;

CREATE PROCEDURE usp_Expense_MarkAsPaid
    @ExpenseID INT
AS
BEGIN
    UPDATE Expense
    SET Status = 'Paid', UpdatedAt = GETUTCDATE()
    WHERE ExpenseID = @ExpenseID AND IsDeleted = 0 AND Status = 'Approved';
END;

CREATE PROCEDURE usp_Expense_Delete
    @Id INT
AS
BEGIN
    UPDATE Expense
    SET IsDeleted = 1, DeletedAt = GETUTCDATE()
    WHERE ExpenseID = @Id AND IsDeleted = 0;
END;

-- ============================================
-- CAMPAIGN PROCEDURES
-- ============================================

CREATE PROCEDURE usp_Campaign_Upsert
    @Id INT = 0,
    @CampaignName NVARCHAR(255),
    @Description NVARCHAR(MAX) = NULL,
    @CampaignType NVARCHAR(50) = NULL,
    @StartDate DATETIME,
    @EndDate DATETIME,
    @BannerImageUrl NVARCHAR(500) = NULL,
    @DiscountType NVARCHAR(50),
    @DiscountValue DECIMAL(10,2),
    @MaxApplicableAmount DECIMAL(10,2) = NULL,
    @TermsConditions NVARCHAR(MAX) = NULL,
    @IsActive BIT = 1,
    @DisplayOrder INT = 0,
    @CreatedBy INT,
    @UpdatedBy INT = NULL,
    @IsDeleted BIT = 0,
    @DeletedAt DATETIME = NULL,
    @DeletedBy INT = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO Campaign (CampaignName, Description, CampaignType, StartDate, EndDate, BannerImageUrl, DiscountType, DiscountValue, MaxApplicableAmount, TermsConditions, IsActive, DisplayOrder, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, IsDeleted, DeletedAt, DeletedBy)
        VALUES (@CampaignName, @Description, @CampaignType, @StartDate, @EndDate, @BannerImageUrl, @DiscountType, @DiscountValue, @MaxApplicableAmount, @TermsConditions, @IsActive, @DisplayOrder, @CreatedBy, GETUTCDATE(), @UpdatedBy, GETUTCDATE(), @IsDeleted, @DeletedAt, @DeletedBy);
    ELSE
        UPDATE Campaign
        SET CampaignName = @CampaignName, Description = @Description, CampaignType = @CampaignType,
            StartDate = @StartDate, EndDate = @EndDate, BannerImageUrl = @BannerImageUrl,
            DiscountType = @DiscountType, DiscountValue = @DiscountValue, MaxApplicableAmount = @MaxApplicableAmount,
            TermsConditions = @TermsConditions, IsActive = @IsActive, DisplayOrder = @DisplayOrder,
            UpdatedBy = @UpdatedBy, UpdatedAt = GETUTCDATE(),
            IsDeleted = @IsDeleted, DeletedAt = @DeletedAt, DeletedBy = @DeletedBy
        WHERE CampaignID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_Campaign_GetById
    @Id INT
AS
BEGIN
    SELECT CampaignID, CampaignName, Description, CampaignType, StartDate, EndDate, BannerImageUrl,
           DiscountType, DiscountValue, MaxApplicableAmount, TermsConditions, IsActive, DisplayOrder,
           CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM Campaign WHERE CampaignID = @Id AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_Campaign_GetActive
    @CurrentDate DATETIME = NULL
AS
BEGIN
    IF @CurrentDate IS NULL SET @CurrentDate = GETUTCDATE();

    SELECT CampaignID, CampaignName, Description, CampaignType, StartDate, EndDate, BannerImageUrl,
           DiscountType, DiscountValue, MaxApplicableAmount, TermsConditions, IsActive, DisplayOrder,
           CreatedBy, CreatedAt, UpdatedBy, UpdatedAt
    FROM Campaign
    WHERE IsActive = 1
      AND StartDate <= @CurrentDate
      AND EndDate >= @CurrentDate
      AND IsDeleted = 0
    ORDER BY DisplayOrder, StartDate DESC;
END;

CREATE PROCEDURE usp_Campaign_GetByType
    @CampaignType NVARCHAR(50)
AS
BEGIN
    SELECT CampaignID, CampaignName, Description, CampaignType, StartDate, EndDate, BannerImageUrl,
           DiscountType, DiscountValue, MaxApplicableAmount, TermsConditions, IsActive, DisplayOrder,
           CreatedBy, CreatedAt, UpdatedBy, UpdatedAt
    FROM Campaign
    WHERE CampaignType = @CampaignType AND IsActive = 1
    ORDER BY DisplayOrder, StartDate DESC;
END;

CREATE PROCEDURE usp_Campaign_GetPaged
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SELECT CampaignID, CampaignName, Description, CampaignType, StartDate, EndDate, BannerImageUrl,
           DiscountType, DiscountValue, MaxApplicableAmount, TermsConditions, IsActive, DisplayOrder,
           CreatedBy, CreatedAt, UpdatedBy, UpdatedAt
    FROM Campaign
    ORDER BY DisplayOrder, StartDate DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    SELECT COUNT(*) AS TotalCount FROM Campaign;
END;

CREATE PROCEDURE usp_Campaign_GetCurrentOffers
    @CurrentDate DATETIME = NULL
AS
BEGIN
    -- Get all active offers/campaigns valid for current date
    IF @CurrentDate IS NULL SET @CurrentDate = GETUTCDATE();

    SELECT CampaignID, CampaignName, Description, CampaignType, StartDate, EndDate, BannerImageUrl,
           DiscountType, DiscountValue, MaxApplicableAmount, TermsConditions, DisplayOrder
    FROM Campaign
    WHERE IsActive = 1
      AND StartDate <= @CurrentDate
      AND EndDate >= @CurrentDate
    ORDER BY DisplayOrder, DiscountValue DESC;
END;

CREATE PROCEDURE usp_Campaign_GetOfferSet
    @DiscountType NVARCHAR(50) = NULL,
    @IsActiveOnly BIT = 1
AS
BEGIN
    -- Get offers filtered by type (Percentage, Fixed, BOGO, FreeAddon)
    -- Returns offers organized in a set for selection
    DECLARE @CurrentDate DATETIME = GETUTCDATE();

    SELECT CampaignID, CampaignName, Description, CampaignType, DiscountType, DiscountValue,
           MaxApplicableAmount, StartDate, EndDate, DisplayOrder
    FROM Campaign
    WHERE (IsActive = @IsActiveOnly OR @IsActiveOnly = 0)
      AND (DiscountType = @DiscountType OR @DiscountType IS NULL)
      AND StartDate <= @CurrentDate
      AND EndDate >= @CurrentDate
    ORDER BY DisplayOrder, DiscountValue DESC;
END;

CREATE PROCEDURE usp_Campaign_Delete
    @Id INT
AS
BEGIN
    DELETE FROM Campaign WHERE CampaignID = @Id;
END;

-- ============================================
-- CAMPAIGN PACKAGE PROCEDURES (Phase 2)
-- ============================================

CREATE PROCEDURE usp_CampaignPackage_Upsert
    @Id INT = 0,
    @CampaignID INT,
    @PackageID INT,
    @IsApplicable BIT = 1,
    @CreatedBy INT = NULL,
    @IsDeleted BIT = 0,
    @DeletedAt DATETIME = NULL,
    @DeletedBy INT = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO CampaignPackage (CampaignID, PackageID, IsApplicable, AppliedAt, CreatedBy, IsDeleted, DeletedAt, DeletedBy)
        VALUES (@CampaignID, @PackageID, @IsApplicable, GETUTCDATE(), @CreatedBy, @IsDeleted, @DeletedAt, @DeletedBy);
    ELSE
        UPDATE CampaignPackage
        SET CampaignID = @CampaignID, PackageID = @PackageID, IsApplicable = @IsApplicable,
            IsDeleted = @IsDeleted, DeletedAt = @DeletedAt, DeletedBy = @DeletedBy
        WHERE CampaignPackageID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_CampaignPackage_GetById
    @Id INT
AS
BEGIN
    SELECT CampaignPackageID, CampaignID, PackageID, IsApplicable, AppliedAt, RemovedAt, CreatedBy, DeletedBy, DeletedAt, IsDeleted
    FROM CampaignPackage WHERE CampaignPackageID = @Id AND IsDeleted = 0;
END;

CREATE PROCEDURE usp_CampaignPackage_GetByCampaign
    @CampaignID INT
AS
BEGIN
    SELECT CampaignPackageID, CampaignID, PackageID, IsApplicable, AppliedAt, RemovedAt, CreatedBy, DeletedBy, DeletedAt, IsDeleted
    FROM CampaignPackage WHERE CampaignID = @CampaignID AND IsApplicable = 1 AND IsDeleted = 0
    ORDER BY AppliedAt DESC;
END;

CREATE PROCEDURE usp_CampaignPackage_GetByPackage
    @PackageID INT
AS
BEGIN
    SELECT CampaignPackageID, CampaignID, PackageID, IsApplicable, AppliedAt, RemovedAt, CreatedBy, DeletedBy, DeletedAt, IsDeleted
    FROM CampaignPackage WHERE PackageID = @PackageID AND IsApplicable = 1 AND IsDeleted = 0
    ORDER BY AppliedAt DESC;
END;

CREATE PROCEDURE usp_CampaignPackage_Delete
    @Id INT
AS
BEGIN
    DELETE FROM CampaignPackage WHERE CampaignPackageID = @Id;
END;

-- ============================================
-- RENTAL CLIENT PROCEDURES (Phase 3)
-- ============================================

CREATE PROCEDURE usp_RentalClient_Upsert
    @Id INT = 0,
    @Email NVARCHAR(255),
    @Phone NVARCHAR(20) = NULL,
    @FullName NVARCHAR(255),
    @Address NVARCHAR(500) = NULL,
    @City NVARCHAR(100) = NULL,
    @State NVARCHAR(50) = NULL,
    @ZipCode NVARCHAR(20) = NULL,
    @ProfilePhotoUrl NVARCHAR(500) = NULL,
    @ValidIDType NVARCHAR(50) = NULL,
    @ValidIDNumber NVARCHAR(100) = NULL,
    @ValidIDPhotoUrl NVARCHAR(500) = NULL,
    @ValidIDExpiry DATETIME = NULL,
    @PreferredContactMethod NVARCHAR(50) = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO RentalClient (Email, Phone, FullName, Address, City, State, ZipCode, ProfilePhotoUrl,
                                  ValidIDType, ValidIDNumber, ValidIDPhotoUrl, ValidIDExpiry, PreferredContactMethod, CreatedAt, UpdatedAt)
        VALUES (@Email, @Phone, @FullName, @Address, @City, @State, @ZipCode, @ProfilePhotoUrl,
                @ValidIDType, @ValidIDNumber, @ValidIDPhotoUrl, @ValidIDExpiry, @PreferredContactMethod, GETUTCDATE(), GETUTCDATE());
    ELSE
        UPDATE RentalClient
        SET Email = @Email, Phone = @Phone, FullName = @FullName, Address = @Address, City = @City, State = @State,
            ZipCode = @ZipCode, ProfilePhotoUrl = @ProfilePhotoUrl, ValidIDType = @ValidIDType, ValidIDNumber = @ValidIDNumber,
            ValidIDPhotoUrl = @ValidIDPhotoUrl, ValidIDExpiry = @ValidIDExpiry, PreferredContactMethod = @PreferredContactMethod,
            UpdatedAt = GETUTCDATE()
        WHERE RentalClientID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_RentalClient_GetById
    @Id INT
AS
BEGIN
    SELECT RentalClientID, Email, Phone, FullName, Address, City, State, ZipCode, ProfilePhotoUrl,
           ValidIDType, ValidIDNumber, ValidIDPhotoUrl, ValidIDExpiry, IsIDVerified, IDVerifiedBy, IDVerifiedAt,
           TotalRentalsCount, TotalRentalSpend, IsBlacklisted, BlacklistedReason,
           AllowEmailCommunication, AllowSMSCommunication, PreferredContactMethod, CreatedAt, UpdatedAt
    FROM RentalClient WHERE RentalClientID = @Id;
END;

CREATE PROCEDURE usp_RentalClient_VerifyID
    @RentalClientID INT,
    @VerifiedBy INT
AS
BEGIN
    UPDATE RentalClient
    SET IsIDVerified = 1, IDVerifiedBy = @VerifiedBy, IDVerifiedAt = GETUTCDATE()
    WHERE RentalClientID = @RentalClientID;
END;

CREATE PROCEDURE usp_RentalClient_Blacklist
    @RentalClientID INT,
    @Reason NVARCHAR(500)
AS
BEGIN
    UPDATE RentalClient
    SET IsBlacklisted = 1, BlacklistedReason = @Reason, UpdatedAt = GETUTCDATE()
    WHERE RentalClientID = @RentalClientID;
END;

CREATE PROCEDURE usp_RentalClient_GetRentalHistory
    @RentalClientID INT
AS
BEGIN
    SELECT ra.RentalAgreementID, ra.EquipmentID, e.Brand, e.Model,
           ra.RentalStartDate, ra.RentalEndDate, ra.RentalCost, ra.Status, ra.PaymentStatus,
           ri.OverallCondition, ri.HasDamage, ra.CreatedAt
    FROM RentalAgreement ra
    LEFT JOIN Equipment e ON ra.EquipmentID = e.EquipmentID
    LEFT JOIN RentalReturnInspection ri ON ra.RentalAgreementID = ri.RentalAgreementID
    WHERE ra.RentalClientID = @RentalClientID
    ORDER BY ra.CreatedAt DESC;
END;

-- ============================================
-- RENTAL AGREEMENT PROCEDURES (Phase 3)
-- ============================================

CREATE PROCEDURE usp_RentalAgreement_Upsert
    @Id INT = 0,
    @RentalClientID INT,
    @EquipmentID INT,
    @RentalStartDate DATETIME,
    @RentalEndDate DATETIME,
    @RentalRate DECIMAL(10,2),
    @RentalCost DECIMAL(10,2),
    @SecurityDeposit DECIMAL(10,2) = NULL,
    @InsuranceRequired BIT = 1,
    @InsuranceType NVARCHAR(100) = NULL,
    @InsuranceCost DECIMAL(10,2) = NULL,
    @MaxDamageDeductible DECIMAL(10,2) = NULL,
    @EquipmentConditionOnHandover NVARCHAR(500) = NULL,
    @CreatedBy INT
AS
BEGIN
    DECLARE @RentalDays INT = DATEDIFF(DAY, @RentalStartDate, @RentalEndDate);

    IF @Id = 0
        INSERT INTO RentalAgreement (RentalClientID, EquipmentID, RentalStartDate, RentalEndDate, RentalDays,
                                     RentalRate, RentalCost, SecurityDeposit, DepositHeldDate,
                                     InsuranceRequired, InsuranceType, InsuranceCost, MaxDamageDeductible,
                                     EquipmentConditionOnHandover, Status, PaymentStatus, CreatedBy, CreatedAt, UpdatedAt)
        VALUES (@RentalClientID, @EquipmentID, @RentalStartDate, @RentalEndDate, @RentalDays,
                @RentalRate, @RentalCost, @SecurityDeposit, GETUTCDATE(),
                @InsuranceRequired, @InsuranceType, @InsuranceCost, @MaxDamageDeductible,
                @EquipmentConditionOnHandover, 'Pending', 'Pending', @CreatedBy, GETUTCDATE(), GETUTCDATE());
    ELSE
        UPDATE RentalAgreement
        SET RentalClientID = @RentalClientID, EquipmentID = @EquipmentID, RentalStartDate = @RentalStartDate,
            RentalEndDate = @RentalEndDate, RentalDays = @RentalDays, RentalRate = @RentalRate,
            RentalCost = @RentalCost, SecurityDeposit = @SecurityDeposit, InsuranceRequired = @InsuranceRequired,
            InsuranceType = @InsuranceType, InsuranceCost = @InsuranceCost, MaxDamageDeductible = @MaxDamageDeductible,
            EquipmentConditionOnHandover = @EquipmentConditionOnHandover, UpdatedAt = GETUTCDATE()
        WHERE RentalAgreementID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_RentalAgreement_GetById
    @Id INT
AS
BEGIN
    SELECT RentalAgreementID, RentalClientID, EquipmentID, RentalStartDate, RentalEndDate, RentalDays,
           RentalRate, RentalCost, SecurityDeposit, DepositHeldDate, DepositReturnedDate,
           InsuranceRequired, InsuranceType, InsuranceCost, MaxDamageDeductible,
           TermsAccepted, TermsAcceptedDate, SignatureUrl, EquipmentConditionOnHandover,
           EquipmentConditionOnReturn, DamageFound, DamageCost, Status, PaymentStatus,
           CreatedBy, CreatedAt, ReturnedAt, UpdatedAt
    FROM RentalAgreement WHERE RentalAgreementID = @Id;
END;

CREATE PROCEDURE usp_RentalAgreement_GetActive
AS
BEGIN
    SELECT ra.RentalAgreementID, rc.FullName, rc.Email, e.Brand, e.Model,
           ra.RentalStartDate, ra.RentalEndDate, ra.RentalCost, ra.SecurityDeposit,
           ra.Status, DATEDIFF(DAY, GETUTCDATE(), ra.RentalEndDate) AS DaysUntilDue
    FROM RentalAgreement ra
    INNER JOIN RentalClient rc ON ra.RentalClientID = rc.RentalClientID
    INNER JOIN Equipment e ON ra.EquipmentID = e.EquipmentID
    WHERE ra.Status = 'Active'
    ORDER BY ra.RentalEndDate ASC;
END;

CREATE PROCEDURE usp_RentalAgreement_GetByClient
    @RentalClientID INT
AS
BEGIN
    SELECT RentalAgreementID, EquipmentID, RentalStartDate, RentalEndDate, RentalCost,
           SecurityDeposit, Status, PaymentStatus, CreatedAt, ReturnedAt
    FROM RentalAgreement
    WHERE RentalClientID = @RentalClientID
    ORDER BY CreatedAt DESC;
END;

CREATE PROCEDURE usp_RentalAgreement_AcceptTerms
    @RentalAgreementID INT,
    @SignatureUrl NVARCHAR(500)
AS
BEGIN
    UPDATE RentalAgreement
    SET TermsAccepted = 1, TermsAcceptedDate = GETUTCDATE(), SignatureUrl = @SignatureUrl, Status = 'Active'
    WHERE RentalAgreementID = @RentalAgreementID;
END;

-- ============================================
-- RENTAL RETURN INSPECTION PROCEDURES (Phase 3)
-- ============================================

CREATE PROCEDURE usp_RentalReturnInspection_Upsert
    @Id INT = 0,
    @RentalAgreementID INT,
    @InspectedBy INT,
    @OverallCondition NVARCHAR(100),
    @HasDamage BIT = 0,
    @DamageDescription NVARCHAR(MAX) = NULL,
    @PhotoUrl NVARCHAR(500) = NULL,
    @EstimatedRepairCost DECIMAL(10,2) = NULL,
    @IsFunctional BIT = 1,
    @TestNotes NVARCHAR(MAX) = NULL,
    @ApprovedBy INT = NULL
AS
BEGIN
    IF @Id = 0
        INSERT INTO RentalReturnInspection (RentalAgreementID, InspectionDate, InspectedBy, OverallCondition,
                                            HasDamage, DamageDescription, PhotoUrl, EstimatedRepairCost,
                                            IsFunctional, TestNotes, ApprovedBy, ApprovedAt, CreatedAt)
        VALUES (@RentalAgreementID, GETUTCDATE(), @InspectedBy, @OverallCondition,
                @HasDamage, @DamageDescription, @PhotoUrl, @EstimatedRepairCost,
                @IsFunctional, @TestNotes, @ApprovedBy, CASE WHEN @ApprovedBy IS NOT NULL THEN GETUTCDATE() ELSE NULL END, GETUTCDATE());
    ELSE
        UPDATE RentalReturnInspection
        SET OverallCondition = @OverallCondition, HasDamage = @HasDamage, DamageDescription = @DamageDescription,
            PhotoUrl = @PhotoUrl, EstimatedRepairCost = @EstimatedRepairCost, IsFunctional = @IsFunctional,
            TestNotes = @TestNotes, ApprovedBy = @ApprovedBy,
            ApprovedAt = CASE WHEN @ApprovedBy IS NOT NULL THEN GETUTCDATE() ELSE NULL END
        WHERE InspectionID = @Id;

    SELECT @@IDENTITY AS Id;
END;

CREATE PROCEDURE usp_RentalReturnInspection_GetByAgreement
    @RentalAgreementID INT
AS
BEGIN
    SELECT InspectionID, RentalAgreementID, InspectionDate, InspectedBy, OverallCondition,
           HasDamage, DamageDescription, PhotoUrl, EstimatedRepairCost, IsFunctional, TestNotes,
           ApprovedBy, ApprovedAt, CreatedAt
    FROM RentalReturnInspection
    WHERE RentalAgreementID = @RentalAgreementID
    ORDER BY InspectionDate DESC;
END;

-- ============================================
-- GAP #8: QUOTATION PROCEDURES (10 procs)
-- ============================================

CREATE OR ALTER PROCEDURE uspQuotationUpsert
    @Id INT = 0,
    @EventID INT,
    @ClientEmail NVARCHAR(255),
    @ClientName NVARCHAR(255),
    @QuotationNumber NVARCHAR(50),
    @ValidUntil DATETIME,
    @SubTotal DECIMAL(10,2),
    @TaxAmount DECIMAL(10,2) = 0,
    @TotalAmount DECIMAL(10,2),
    @Status NVARCHAR(50) = 'Draft',
    @Notes NVARCHAR(MAX),
    @ViewedAt DATETIME = NULL,
    @AcceptedAt DATETIME = NULL,
    @DeclinedAt DATETIME = NULL,
    @RejectionReason NVARCHAR(500) = NULL,
    @CreatedBy INT,
    @UpdatedBy INT = NULL,
    @DeletedBy INT = NULL,
    @IsDeleted BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id = 0
    BEGIN
        INSERT INTO Quotation (EventID, ClientEmail, ClientName, QuotationNumber, QuotationDate, ValidUntil, SubTotal, TaxAmount, TotalAmount, Status, Notes, ViewedAt, AcceptedAt, DeclinedAt, RejectionReason, CreatedBy, UpdatedBy, CreatedAt)
        VALUES (@EventID, @ClientEmail, @ClientName, @QuotationNumber, GETUTCDATE(), @ValidUntil, @SubTotal, @TaxAmount, @TotalAmount, @Status, @Notes, @ViewedAt, @AcceptedAt, @DeclinedAt, @RejectionReason, @CreatedBy, @UpdatedBy, GETUTCDATE());
        SET @Id = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE Quotation
        SET EventID = @EventID, ClientEmail = @ClientEmail, ClientName = @ClientName, ValidUntil = @ValidUntil, SubTotal = @SubTotal, TaxAmount = @TaxAmount, TotalAmount = @TotalAmount, Status = @Status, Notes = @Notes, ViewedAt = @ViewedAt, AcceptedAt = @AcceptedAt, DeclinedAt = @DeclinedAt, RejectionReason = @RejectionReason, UpdatedBy = @UpdatedBy, UpdatedAt = GETUTCDATE(), DeletedBy = @DeletedBy, IsDeleted = @IsDeleted
        WHERE QuotationID = @Id;
    END

    SELECT @Id AS QuotationID;
END;

CREATE OR ALTER PROCEDURE uspQuotationRead
    @Id INT
AS
BEGIN
    SELECT QuotationID, EventID, ClientEmail, ClientName, QuotationNumber, QuotationDate, ValidUntil, SubTotal, TaxAmount, TotalAmount, Status, Notes, ViewedAt, AcceptedAt, DeclinedAt, RejectionReason, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, IsDeleted, DeletedAt, DeletedBy
    FROM Quotation
    WHERE QuotationID = @Id AND IsDeleted = 0;
END;

CREATE OR ALTER PROCEDURE uspQuotationReadAll
AS
BEGIN
    SELECT QuotationID, EventID, ClientEmail, ClientName, QuotationNumber, QuotationDate, ValidUntil, SubTotal, TaxAmount, TotalAmount, Status, Notes, ViewedAt, AcceptedAt, DeclinedAt, RejectionReason, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, IsDeleted, DeletedAt, DeletedBy
    FROM Quotation
    WHERE IsDeleted = 0
    ORDER BY QuotationDate DESC;
END;

CREATE OR ALTER PROCEDURE uspQuotationReadPaged
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SELECT QuotationID, EventID, ClientEmail, ClientName, QuotationNumber, QuotationDate, ValidUntil, SubTotal, TaxAmount, TotalAmount, Status, Notes, ViewedAt, AcceptedAt, DeclinedAt, RejectionReason, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, IsDeleted, DeletedAt, DeletedBy
    FROM Quotation
    WHERE IsDeleted = 0
    ORDER BY QuotationDate DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;

CREATE OR ALTER PROCEDURE uspQuotationGetByEvent
    @EventID INT
AS
BEGIN
    SELECT QuotationID, EventID, ClientEmail, ClientName, QuotationNumber, QuotationDate, ValidUntil, SubTotal, TaxAmount, TotalAmount, Status, Notes, ViewedAt, AcceptedAt, DeclinedAt, RejectionReason, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, IsDeleted, DeletedAt, DeletedBy
    FROM Quotation
    WHERE EventID = @EventID AND IsDeleted = 0
    ORDER BY QuotationDate DESC;
END;

CREATE OR ALTER PROCEDURE uspQuotationGetByClient
    @ClientEmail NVARCHAR(255)
AS
BEGIN
    SELECT QuotationID, EventID, ClientEmail, ClientName, QuotationNumber, QuotationDate, ValidUntil, SubTotal, TaxAmount, TotalAmount, Status, Notes, ViewedAt, AcceptedAt, DeclinedAt, RejectionReason, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, IsDeleted, DeletedAt, DeletedBy
    FROM Quotation
    WHERE ClientEmail = @ClientEmail AND IsDeleted = 0
    ORDER BY QuotationDate DESC;
END;

CREATE OR ALTER PROCEDURE uspQuotationGetByStatus
    @Status NVARCHAR(50)
AS
BEGIN
    SELECT QuotationID, EventID, ClientEmail, ClientName, QuotationNumber, QuotationDate, ValidUntil, SubTotal, TaxAmount, TotalAmount, Status, Notes, ViewedAt, AcceptedAt, DeclinedAt, RejectionReason, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, IsDeleted, DeletedAt, DeletedBy
    FROM Quotation
    WHERE Status = @Status AND IsDeleted = 0
    ORDER BY QuotationDate DESC;
END;

CREATE OR ALTER PROCEDURE uspQuotationAccept
    @QuotationID INT,
    @UpdatedByUserID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Quotation
    SET AcceptedAt = GETUTCDATE(), Status = 'Accepted', UpdatedBy = @UpdatedByUserID, UpdatedAt = GETUTCDATE()
    WHERE QuotationID = @QuotationID;

    SELECT @QuotationID AS QuotationID;
END;

CREATE OR ALTER PROCEDURE uspQuotationDecline
    @QuotationID INT,
    @RejectionReason NVARCHAR(500),
    @UpdatedByUserID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Quotation
    SET DeclinedAt = GETUTCDATE(), RejectionReason = @RejectionReason, Status = 'Rejected', UpdatedBy = @UpdatedByUserID, UpdatedAt = GETUTCDATE()
    WHERE QuotationID = @QuotationID;

    SELECT @QuotationID AS QuotationID;
END;

CREATE OR ALTER PROCEDURE uspQuotationDelete
    @QuotationID INT,
    @DeletedByUserID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Quotation
    SET IsDeleted = 1, DeletedAt = GETUTCDATE(), DeletedBy = @DeletedByUserID
    WHERE QuotationID = @QuotationID;

    SELECT @QuotationID AS QuotationID;
END;

-- ============================================
-- GAP #9: USER PHOTOGRAPHER PROCEDURES (6 procs)
-- ============================================

CREATE OR ALTER PROCEDURE uspUserUpsert
    @Id INT = 0,
    @Email NVARCHAR(255),
    @PasswordHash NVARCHAR(255),
    @FullName NVARCHAR(255),
    @Phone NVARCHAR(20) = NULL,
    @Bio NVARCHAR(MAX) = NULL,
    @ProfilePhotoUrl NVARCHAR(500) = NULL,
    @IsPhotographer BIT = 0,
    @HourlyRate DECIMAL(10,2) = NULL,
    @DailyRate DECIMAL(10,2) = NULL,
    @MaxBookingsPerMonth INT = NULL,
    @PreferredWorkingHours NVARCHAR(500) = NULL,
    @IsActive BIT = 1,
    @CreatedBy INT = NULL,
    @UpdatedBy INT = NULL,
    @DeletedBy INT = NULL,
    @IsDeleted BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id = 0
    BEGIN
        INSERT INTO Users (Email, PasswordHash, FullName, Phone, Bio, ProfilePhotoUrl, IsPhotographer, HourlyRate, DailyRate, MaxBookingsPerMonth, PreferredWorkingHours, IsActive, CreatedAt, UpdatedAt)
        VALUES (@Email, @PasswordHash, @FullName, @Phone, @Bio, @ProfilePhotoUrl, @IsPhotographer, @HourlyRate, @DailyRate, @MaxBookingsPerMonth, @PreferredWorkingHours, @IsActive, GETUTCDATE(), GETUTCDATE());
        SET @Id = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE Users
        SET Email = @Email, PasswordHash = @PasswordHash, FullName = @FullName, Phone = @Phone, Bio = @Bio, ProfilePhotoUrl = @ProfilePhotoUrl, IsPhotographer = @IsPhotographer, HourlyRate = @HourlyRate, DailyRate = @DailyRate, MaxBookingsPerMonth = @MaxBookingsPerMonth, PreferredWorkingHours = @PreferredWorkingHours, IsActive = @IsActive, UpdatedAt = GETUTCDATE()
        WHERE UserID = @Id;
    END

    SELECT @Id AS UserID;
END;

CREATE OR ALTER PROCEDURE uspUserRead
    @Id INT
AS
BEGIN
    SELECT UserID, Email, PasswordHash, FullName, Phone, Bio, ProfilePhotoUrl, IsPhotographer, HourlyRate, DailyRate, MaxBookingsPerMonth, PreferredWorkingHours, IsActive, CreatedAt, UpdatedAt
    FROM Users
    WHERE UserID = @Id AND IsActive = 1;
END;

CREATE OR ALTER PROCEDURE uspUserReadAll
AS
BEGIN
    SELECT UserID, Email, PasswordHash, FullName, Phone, Bio, ProfilePhotoUrl, IsPhotographer, HourlyRate, DailyRate, MaxBookingsPerMonth, PreferredWorkingHours, IsActive, CreatedAt, UpdatedAt
    FROM Users
    WHERE IsActive = 1
    ORDER BY FullName ASC;
END;

CREATE OR ALTER PROCEDURE uspUserGetPhotographers
AS
BEGIN
    SELECT UserID, Email, PasswordHash, FullName, Phone, Bio, ProfilePhotoUrl, IsPhotographer, HourlyRate, DailyRate, MaxBookingsPerMonth, PreferredWorkingHours, IsActive, CreatedAt, UpdatedAt
    FROM Users
    WHERE IsPhotographer = 1 AND IsActive = 1
    ORDER BY FullName ASC;
END;

CREATE OR ALTER PROCEDURE uspUserGetByRate
    @MinRate DECIMAL(10,2),
    @MaxRate DECIMAL(10,2)
AS
BEGIN
    SELECT UserID, Email, PasswordHash, FullName, Phone, Bio, ProfilePhotoUrl, IsPhotographer, HourlyRate, DailyRate, MaxBookingsPerMonth, PreferredWorkingHours, IsActive, CreatedAt, UpdatedAt
    FROM Users
    WHERE IsPhotographer = 1 AND IsActive = 1 AND HourlyRate BETWEEN @MinRate AND @MaxRate
    ORDER BY HourlyRate ASC;
END;

CREATE OR ALTER PROCEDURE uspUserGetByAvailability
    @MonthDate DATETIME
AS
BEGIN
    DECLARE @StartDate DATETIME = DATEFROMPARTS(YEAR(@MonthDate), MONTH(@MonthDate), 1);
    DECLARE @EndDate DATETIME = EOMONTH(@MonthDate);

    SELECT DISTINCT u.UserID, u.Email, u.PasswordHash, u.FullName, u.Phone, u.Bio, u.ProfilePhotoUrl, u.IsPhotographer, u.HourlyRate, u.DailyRate, u.MaxBookingsPerMonth, u.PreferredWorkingHours, u.IsActive, u.CreatedAt, u.UpdatedAt
    FROM Users u
    INNER JOIN Availability a ON u.UserID = a.PhotographerUserID
    WHERE u.IsPhotographer = 1
      AND u.IsActive = 1
      AND a.IsAvailable = 1
      AND a.IsDeleted = 0
      AND a.AvailabilityStart <= @EndDate
      AND a.AvailabilityEnd >= @StartDate
    ORDER BY u.FullName ASC;
END;

-- ============================================
-- GAP #10: LOCATION FEE PROCEDURES (8 procs)
-- ============================================

CREATE OR ALTER PROCEDURE uspLocationFeeUpsert
    @Id INT = 0,
    @LocationName NVARCHAR(255),
    @City NVARCHAR(100),
    @State NVARCHAR(50),
    @ZipCode NVARCHAR(20),
    @TravelMinutes INT,
    @SurchargeAmount DECIMAL(10,2),
    @SurchargeType NVARCHAR(50),
    @IsActive BIT = 1,
    @CreatedBy INT,
    @UpdatedBy INT = NULL,
    @DeletedBy INT = NULL,
    @IsDeleted BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id = 0
    BEGIN
        INSERT INTO LocationFee (LocationName, City, State, ZipCode, TravelMinutes, SurchargeAmount, SurchargeType, IsActive, CreatedBy, UpdatedBy, CreatedAt)
        VALUES (@LocationName, @City, @State, @ZipCode, @TravelMinutes, @SurchargeAmount, @SurchargeType, @IsActive, @CreatedBy, @UpdatedBy, GETUTCDATE());
        SET @Id = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE LocationFee
        SET LocationName = @LocationName, City = @City, State = @State, ZipCode = @ZipCode, TravelMinutes = @TravelMinutes, SurchargeAmount = @SurchargeAmount, SurchargeType = @SurchargeType, IsActive = @IsActive, UpdatedBy = @UpdatedBy, UpdatedAt = GETUTCDATE(), DeletedBy = @DeletedBy, IsDeleted = @IsDeleted
        WHERE LocationFeeID = @Id;
    END

    SELECT @Id AS LocationFeeID;
END;

CREATE OR ALTER PROCEDURE uspLocationFeeRead
    @Id INT
AS
BEGIN
    SELECT LocationFeeID, LocationName, City, State, ZipCode, TravelMinutes, SurchargeAmount, SurchargeType, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM LocationFee
    WHERE LocationFeeID = @Id AND IsDeleted = 0;
END;

CREATE OR ALTER PROCEDURE uspLocationFeeReadAll
AS
BEGIN
    SELECT LocationFeeID, LocationName, City, State, ZipCode, TravelMinutes, SurchargeAmount, SurchargeType, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM LocationFee
    WHERE IsActive = 1 AND IsDeleted = 0
    ORDER BY City ASC, LocationName ASC;
END;

CREATE OR ALTER PROCEDURE uspLocationFeeGetByCity
    @City NVARCHAR(100)
AS
BEGIN
    SELECT LocationFeeID, LocationName, City, State, ZipCode, TravelMinutes, SurchargeAmount, SurchargeType, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM LocationFee
    WHERE City = @City AND IsDeleted = 0
    ORDER BY LocationName ASC;
END;

CREATE OR ALTER PROCEDURE uspLocationFeeGetByState
    @State NVARCHAR(50)
AS
BEGIN
    SELECT LocationFeeID, LocationName, City, State, ZipCode, TravelMinutes, SurchargeAmount, SurchargeType, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM LocationFee
    WHERE State = @State AND IsDeleted = 0
    ORDER BY City ASC, LocationName ASC;
END;

CREATE OR ALTER PROCEDURE uspLocationFeeGetBySurcharge
    @SurchargeAmount DECIMAL(10,2)
AS
BEGIN
    SELECT LocationFeeID, LocationName, City, State, ZipCode, TravelMinutes, SurchargeAmount, SurchargeType, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM LocationFee
    WHERE SurchargeAmount = @SurchargeAmount AND IsDeleted = 0
    ORDER BY City ASC, LocationName ASC;
END;

CREATE OR ALTER PROCEDURE uspLocationFeeDelete
    @LocationFeeID INT,
    @DeletedByUserID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE LocationFee
    SET IsDeleted = 1, DeletedAt = GETUTCDATE(), DeletedBy = @DeletedByUserID
    WHERE LocationFeeID = @LocationFeeID;

    SELECT @LocationFeeID AS LocationFeeID;
END;

-- ============================================
-- GAP #10b: BOOKING HELPER PROCEDURES (2 procs)
-- ============================================

CREATE OR ALTER PROCEDURE uspBookingAddLocationFee
    @BookingID INT,
    @LocationFeeID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SurchargeAmount DECIMAL(10,2);

    SELECT @SurchargeAmount = SurchargeAmount FROM LocationFee WHERE LocationFeeID = @LocationFeeID AND IsDeleted = 0;

    UPDATE Booking
    SET LocationFeeID = @LocationFeeID, TravelSurcharge = ISNULL(@SurchargeAmount, 0), UpdatedAt = GETUTCDATE()
    WHERE BookingID = @BookingID;

    SELECT @BookingID AS BookingID, @SurchargeAmount AS TravelSurcharge;
END;

CREATE OR ALTER PROCEDURE uspBookingCalculateTravelFee
    @LocationFeeID INT
AS
BEGIN
    DECLARE @SurchargeAmount DECIMAL(10,2);

    SELECT @SurchargeAmount = SurchargeAmount FROM LocationFee WHERE LocationFeeID = @LocationFeeID AND IsDeleted = 0;

    SELECT @SurchargeAmount AS SurchargeAmount;
END;

-- ============================================
-- COMMUNICATION PROCEDURES (Generic for Any Entity)
-- ============================================

CREATE OR ALTER PROCEDURE uspCommunicationUpsert
    @CommunicationID INT = 0,
    @EntityType NVARCHAR(50),
    @EntityID INT,
    @FromUserID INT,
    @ToClientID INT = NULL,
    @ToEmail NVARCHAR(255),
    @Subject NVARCHAR(255) = NULL,
    @Message NVARCHAR(MAX),
    @MessageType NVARCHAR(50),
    @Status NVARCHAR(50) = 'Sent',
    @IsInternal BIT = 0,
    @IsAutomatic BIT = 0,
    @TemplateUsed NVARCHAR(255) = NULL,
    @SentAt DATETIME = NULL,
    @DeliveredAt DATETIME = NULL,
    @ReadAt DATETIME = NULL,
    @CreatedBy INT,
    @UpdatedBy INT = NULL,
    @DeletedBy INT = NULL,
    @IsDeleted BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @CommunicationID = 0
    BEGIN
        INSERT INTO Communication (EntityType, EntityID, FromUserID, ToClientID, ToEmail, Subject, Message, MessageType, Status, IsInternal, IsAutomatic, TemplateUsed, SentAt, DeliveredAt, ReadAt, CreatedBy, UpdatedBy, IsDeleted, CreatedAt)
        VALUES (@EntityType, @EntityID, @FromUserID, @ToClientID, @ToEmail, @Subject, @Message, @MessageType, @Status, @IsInternal, @IsAutomatic, @TemplateUsed, @SentAt, @DeliveredAt, @ReadAt, @CreatedBy, @UpdatedBy, @IsDeleted, GETUTCDATE());
        SET @CommunicationID = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE Communication
        SET EntityType = @EntityType, EntityID = @EntityID, FromUserID = @FromUserID, ToClientID = @ToClientID, ToEmail = @ToEmail, Subject = @Subject, Message = @Message, MessageType = @MessageType, Status = @Status, IsInternal = @IsInternal, IsAutomatic = @IsAutomatic, TemplateUsed = @TemplateUsed, SentAt = @SentAt, DeliveredAt = @DeliveredAt, ReadAt = @ReadAt, UpdatedBy = @UpdatedBy, UpdatedAt = GETUTCDATE(), DeletedBy = @DeletedBy, IsDeleted = @IsDeleted
        WHERE CommunicationID = @CommunicationID;
    END

    SELECT @CommunicationID AS CommunicationID;
END;

CREATE OR ALTER PROCEDURE uspCommunicationRead
    @CommunicationID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CommunicationID, EntityType, EntityID, FromUserID, ToClientID, ToEmail, Subject, Message, MessageType, Status, IsInternal, IsAutomatic, TemplateUsed, CreatedAt, SentAt, DeliveredAt, ReadAt, CreatedBy, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM Communication
    WHERE CommunicationID = @CommunicationID AND IsDeleted = 0;
END;

CREATE OR ALTER PROCEDURE uspCommunicationReadAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CommunicationID, EntityType, EntityID, FromUserID, ToClientID, ToEmail, Subject, Message, MessageType, Status, IsInternal, IsAutomatic, TemplateUsed, CreatedAt, SentAt, DeliveredAt, ReadAt, CreatedBy, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM Communication
    WHERE IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE OR ALTER PROCEDURE uspCommunicationReadPaged
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    SELECT CommunicationID, EntityType, EntityID, FromUserID, ToClientID, ToEmail, Subject, Message, MessageType, Status, IsInternal, IsAutomatic, TemplateUsed, CreatedAt, SentAt, DeliveredAt, ReadAt, CreatedBy, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM Communication
    WHERE IsDeleted = 0
    ORDER BY CreatedAt DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;

CREATE OR ALTER PROCEDURE uspCommunicationGetByEntity
    @EntityType NVARCHAR(50),
    @EntityID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CommunicationID, EntityType, EntityID, FromUserID, ToClientID, ToEmail, Subject, Message, MessageType, Status, IsInternal, IsAutomatic, TemplateUsed, CreatedAt, SentAt, DeliveredAt, ReadAt, CreatedBy, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM Communication
    WHERE EntityType = @EntityType AND EntityID = @EntityID AND IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE OR ALTER PROCEDURE uspCommunicationGetByClient
    @ToClientID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CommunicationID, EntityType, EntityID, FromUserID, ToClientID, ToEmail, Subject, Message, MessageType, Status, IsInternal, IsAutomatic, TemplateUsed, CreatedAt, SentAt, DeliveredAt, ReadAt, CreatedBy, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM Communication
    WHERE ToClientID = @ToClientID AND IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE OR ALTER PROCEDURE uspCommunicationGetByEmail
    @ToEmail NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CommunicationID, EntityType, EntityID, FromUserID, ToClientID, ToEmail, Subject, Message, MessageType, Status, IsInternal, IsAutomatic, TemplateUsed, CreatedAt, SentAt, DeliveredAt, ReadAt, CreatedBy, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM Communication
    WHERE ToEmail = @ToEmail AND IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE OR ALTER PROCEDURE uspCommunicationGetByStatus
    @Status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CommunicationID, EntityType, EntityID, FromUserID, ToClientID, ToEmail, Subject, Message, MessageType, Status, IsInternal, IsAutomatic, TemplateUsed, CreatedAt, SentAt, DeliveredAt, ReadAt, CreatedBy, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM Communication
    WHERE Status = @Status AND IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE OR ALTER PROCEDURE uspCommunicationGetUnread
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CommunicationID, EntityType, EntityID, FromUserID, ToClientID, ToEmail, Subject, Message, MessageType, Status, IsInternal, IsAutomatic, TemplateUsed, CreatedAt, SentAt, DeliveredAt, ReadAt, CreatedBy, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM Communication
    WHERE (Status = 'Sent' OR Status != 'Read') AND IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE OR ALTER PROCEDURE uspCommunicationMarkRead
    @CommunicationID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Communication
    SET ReadAt = GETUTCDATE(), Status = 'Read', UpdatedAt = GETUTCDATE()
    WHERE CommunicationID = @CommunicationID AND IsDeleted = 0;

    SELECT @CommunicationID AS CommunicationID;
END;

CREATE OR ALTER PROCEDURE uspCommunicationMarkDelivered
    @CommunicationID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Communication
    SET DeliveredAt = GETUTCDATE(), Status = 'Delivered', UpdatedAt = GETUTCDATE()
    WHERE CommunicationID = @CommunicationID AND IsDeleted = 0;

    SELECT @CommunicationID AS CommunicationID;
END;

CREATE OR ALTER PROCEDURE uspCommunicationDelete
    @CommunicationID INT,
    @DeletedByUserID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Communication
    SET IsDeleted = 1, DeletedAt = GETUTCDATE(), DeletedBy = @DeletedByUserID, UpdatedAt = GETUTCDATE()
    WHERE CommunicationID = @CommunicationID;

    SELECT @CommunicationID AS CommunicationID;
END;

-- ============================================
-- PORTFOLIO SHOWCASE PROCEDURES
-- ============================================

CREATE OR ALTER PROCEDURE uspPortfolioShowcaseUpsert
    @Id INT = 0,
    @EventID INT = NULL,
    @ServiceCategory NVARCHAR(100) = NULL,
    @BeforeGalleryID INT,
    @AfterGalleryID INT,
    @Description NVARCHAR(MAX) = NULL,
    @FeaturedRating INT = NULL,
    @CreatedBy INT,
    @UpdatedBy INT = NULL,
    @DeletedBy INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id = 0
        INSERT INTO PortfolioShowcase (EventID, ServiceCategory, BeforeGalleryID, AfterGalleryID, Description, FeaturedRating, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, IsDeleted)
        VALUES (@EventID, @ServiceCategory, @BeforeGalleryID, @AfterGalleryID, @Description, @FeaturedRating, @CreatedBy, GETUTCDATE(), @UpdatedBy, GETUTCDATE(), 0);
    ELSE
        UPDATE PortfolioShowcase
        SET EventID = @EventID, ServiceCategory = @ServiceCategory, BeforeGalleryID = @BeforeGalleryID, AfterGalleryID = @AfterGalleryID,
            Description = @Description, FeaturedRating = @FeaturedRating, UpdatedBy = @UpdatedBy, UpdatedAt = GETUTCDATE()
        WHERE ShowcaseID = @Id AND IsDeleted = 0;

    SELECT @@IDENTITY AS Id;
END;

CREATE OR ALTER PROCEDURE uspPortfolioShowcaseRead
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ShowcaseID, EventID, ServiceCategory, BeforeGalleryID, AfterGalleryID, Description, FeaturedRating, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM PortfolioShowcase
    WHERE ShowcaseID = @Id AND IsDeleted = 0;
END;

CREATE OR ALTER PROCEDURE uspPortfolioShowcaseReadAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ShowcaseID, EventID, ServiceCategory, BeforeGalleryID, AfterGalleryID, Description, FeaturedRating, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM PortfolioShowcase
    WHERE IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE OR ALTER PROCEDURE uspPortfolioShowcaseReadPaged
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @ServiceCategory NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    SELECT ShowcaseID, EventID, ServiceCategory, BeforeGalleryID, AfterGalleryID, Description, FeaturedRating, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM PortfolioShowcase
    WHERE IsDeleted = 0 AND (@ServiceCategory IS NULL OR ServiceCategory = @ServiceCategory)
    ORDER BY CreatedAt DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;

CREATE OR ALTER PROCEDURE uspPortfolioShowcaseGetByEvent
    @EventID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ShowcaseID, EventID, ServiceCategory, BeforeGalleryID, AfterGalleryID, Description, FeaturedRating, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM PortfolioShowcase
    WHERE EventID = @EventID AND IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE OR ALTER PROCEDURE uspPortfolioShowcaseGetByServiceCategory
    @ServiceCategory NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ShowcaseID, EventID, ServiceCategory, BeforeGalleryID, AfterGalleryID, Description, FeaturedRating, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM PortfolioShowcase
    WHERE ServiceCategory = @ServiceCategory AND IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE OR ALTER PROCEDURE uspPortfolioShowcaseGetByRating
    @MinimumRating INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ShowcaseID, EventID, ServiceCategory, BeforeGalleryID, AfterGalleryID, Description, FeaturedRating, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM PortfolioShowcase
    WHERE FeaturedRating >= @MinimumRating AND IsDeleted = 0
    ORDER BY FeaturedRating DESC, CreatedAt DESC;
END;

CREATE OR ALTER PROCEDURE uspPortfolioShowcaseDelete
    @ShowcaseID INT,
    @DeletedBy INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE PortfolioShowcase
    SET IsDeleted = 1, DeletedAt = GETUTCDATE(), DeletedBy = @DeletedBy, UpdatedAt = GETUTCDATE()
    WHERE ShowcaseID = @ShowcaseID AND IsDeleted = 0;

    SELECT @ShowcaseID AS ShowcaseID;
END;

-- ============================================
-- EMAIL TEMPLATE PROCEDURES
-- ============================================

CREATE PROCEDURE uspEmailTemplateUpsert
    @Id INT = 0,
    @TemplateName NVARCHAR(255),
    @TemplateType NVARCHAR(50),
    @Subject NVARCHAR(500),
    @HtmlBody NVARCHAR(MAX),
    @PlaceholderVariables NVARCHAR(500) = NULL,
    @IsActive BIT = 1,
    @CreatedBy INT = NULL,
    @UpdatedBy INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id = 0
    BEGIN
        -- INSERT
        INSERT INTO EmailTemplate (TemplateName, TemplateType, Subject, HtmlBody, PlaceholderVariables, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt)
        VALUES (@TemplateName, @TemplateType, @Subject, @HtmlBody, @PlaceholderVariables, @IsActive, @CreatedBy, GETUTCDATE(), @UpdatedBy, GETUTCDATE());

        SELECT CAST(@@IDENTITY AS INT) AS TemplateID;
    END
    ELSE
    BEGIN
        -- UPDATE
        UPDATE EmailTemplate
        SET TemplateName = @TemplateName, TemplateType = @TemplateType, Subject = @Subject, HtmlBody = @HtmlBody,
            PlaceholderVariables = @PlaceholderVariables, IsActive = @IsActive, UpdatedBy = @UpdatedBy, UpdatedAt = GETUTCDATE()
        WHERE TemplateID = @Id AND IsDeleted = 0;

        SELECT @Id AS TemplateID;
    END
END;

CREATE PROCEDURE uspEmailTemplateRead
    @TemplateID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TemplateID, TemplateName, TemplateType, Subject, HtmlBody, PlaceholderVariables, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM EmailTemplate
    WHERE TemplateID = @TemplateID AND IsDeleted = 0;
END;

CREATE PROCEDURE uspEmailTemplateReadAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TemplateID, TemplateName, TemplateType, Subject, HtmlBody, PlaceholderVariables, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt
    FROM EmailTemplate
    WHERE IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE PROCEDURE uspEmailTemplateReadPaged
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @TemplateType NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    -- Get paged results
    SELECT TemplateID, TemplateName, TemplateType, Subject, PlaceholderVariables, IsActive, CreatedBy, CreatedAt, UpdatedAt
    FROM EmailTemplate
    WHERE IsDeleted = 0 AND (@TemplateType IS NULL OR TemplateType = @TemplateType)
    ORDER BY CreatedAt DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    -- Get total count
    SELECT COUNT(*) AS TotalCount
    FROM EmailTemplate
    WHERE IsDeleted = 0 AND (@TemplateType IS NULL OR TemplateType = @TemplateType);
END;

CREATE PROCEDURE uspEmailTemplateGetByType
    @TemplateType NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TemplateID, TemplateName, TemplateType, Subject, PlaceholderVariables, IsActive, CreatedBy, CreatedAt, UpdatedAt
    FROM EmailTemplate
    WHERE TemplateType = @TemplateType AND IsDeleted = 0
    ORDER BY TemplateName;
END;

CREATE PROCEDURE uspEmailTemplateGetActive
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TemplateID, TemplateName, TemplateType, Subject, HtmlBody, PlaceholderVariables, CreatedBy, CreatedAt, UpdatedAt
    FROM EmailTemplate
    WHERE IsActive = 1 AND IsDeleted = 0
    ORDER BY TemplateName;
END;

CREATE PROCEDURE uspEmailTemplateGetByName
    @TemplateName NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TemplateID, TemplateName, TemplateType, Subject, HtmlBody, PlaceholderVariables, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt
    FROM EmailTemplate
    WHERE TemplateName = @TemplateName AND IsDeleted = 0;
END;

CREATE PROCEDURE uspEmailTemplateDelete
    @TemplateID INT,
    @DeletedBy INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE EmailTemplate
    SET IsDeleted = 1, DeletedAt = GETUTCDATE(), DeletedBy = @DeletedBy, UpdatedAt = GETUTCDATE()
    WHERE TemplateID = @TemplateID AND IsDeleted = 0;

    SELECT @TemplateID AS TemplateID;
END;

-- ============================================
-- CONTRACT TEMPLATE PROCEDURES (Gap #18)
-- ============================================

CREATE PROCEDURE uspContractTemplateUpsert
    @Id INT = 0,
    @ContractName NVARCHAR(255),
    @ServiceCategory NVARCHAR(100) = NULL,
    @TemplateText NVARCHAR(MAX),
    @PlaceholderVariables NVARCHAR(500) = NULL,
    @IsActive BIT = 1,
    @CreatedBy INT = NULL,
    @LastUpdatedBy INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id = 0
    BEGIN
        IF @CreatedBy IS NULL
            RAISERROR('CreatedBy is required for new records.', 16, 1);

        INSERT INTO ContractTemplate (ContractName, ServiceCategory, TemplateText, PlaceholderVariables, IsActive, CreatedBy, CreatedAt, LastUpdatedBy, LastUpdatedAt)
        VALUES (@ContractName, @ServiceCategory, @TemplateText, @PlaceholderVariables, @IsActive, @CreatedBy, GETUTCDATE(), @LastUpdatedBy, GETUTCDATE());
    END
    ELSE
        UPDATE ContractTemplate
        SET ContractName = @ContractName, ServiceCategory = @ServiceCategory, TemplateText = @TemplateText,
            PlaceholderVariables = @PlaceholderVariables, IsActive = @IsActive, LastUpdatedBy = @LastUpdatedBy, LastUpdatedAt = GETUTCDATE()
        WHERE ContractTemplateID = @Id;

    SELECT @@IDENTITY AS ContractTemplateID;
END;

CREATE PROCEDURE uspContractTemplateRead
    @ContractTemplateID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ContractTemplateID, ContractName, ServiceCategory, TemplateText, PlaceholderVariables, IsActive, CreatedBy, CreatedAt, LastUpdatedBy, LastUpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM ContractTemplate
    WHERE ContractTemplateID = @ContractTemplateID AND IsDeleted = 0;
END;

CREATE PROCEDURE uspContractTemplateReadAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ContractTemplateID, ContractName, ServiceCategory, TemplateText, PlaceholderVariables, IsActive, CreatedBy, CreatedAt, LastUpdatedBy, LastUpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM ContractTemplate
    WHERE IsActive = 1 AND IsDeleted = 0
    ORDER BY ContractName ASC;
END;

CREATE PROCEDURE uspContractTemplateReadPaged
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @ServiceCategory NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @ServiceCategory IS NULL
    BEGIN
        SELECT ContractTemplateID, ContractName, ServiceCategory, TemplateText, PlaceholderVariables, IsActive, CreatedBy, CreatedAt, LastUpdatedBy, LastUpdatedAt, DeletedBy, DeletedAt, IsDeleted
        FROM ContractTemplate
        WHERE IsDeleted = 0
        ORDER BY ContractName ASC
        OFFSET (@PageNumber - 1) * @PageSize ROWS
        FETCH NEXT @PageSize ROWS ONLY;

        SELECT COUNT(*) AS TotalCount
        FROM ContractTemplate
        WHERE IsDeleted = 0;
    END
    ELSE
    BEGIN
        SELECT ContractTemplateID, ContractName, ServiceCategory, TemplateText, PlaceholderVariables, IsActive, CreatedBy, CreatedAt, LastUpdatedBy, LastUpdatedAt, DeletedBy, DeletedAt, IsDeleted
        FROM ContractTemplate
        WHERE ServiceCategory = @ServiceCategory AND IsDeleted = 0
        ORDER BY ContractName ASC
        OFFSET (@PageNumber - 1) * @PageSize ROWS
        FETCH NEXT @PageSize ROWS ONLY;

        SELECT COUNT(*) AS TotalCount
        FROM ContractTemplate
        WHERE ServiceCategory = @ServiceCategory AND IsDeleted = 0;
    END
END;

CREATE PROCEDURE uspContractTemplateGetByCategory
    @ServiceCategory NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ContractTemplateID, ContractName, ServiceCategory, TemplateText, PlaceholderVariables, IsActive, CreatedBy, CreatedAt, LastUpdatedBy, LastUpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM ContractTemplate
    WHERE ServiceCategory = @ServiceCategory AND IsActive = 1 AND IsDeleted = 0
    ORDER BY ContractName ASC;
END;

CREATE PROCEDURE uspContractTemplateGetActive
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ContractTemplateID, ContractName, ServiceCategory, TemplateText, PlaceholderVariables, CreatedBy, CreatedAt, LastUpdatedBy, LastUpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM ContractTemplate
    WHERE IsActive = 1 AND IsDeleted = 0
    ORDER BY ServiceCategory ASC, ContractName ASC;
END;

CREATE PROCEDURE uspContractTemplateGetByName
    @ContractName NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ContractTemplateID, ContractName, ServiceCategory, TemplateText, PlaceholderVariables, IsActive, CreatedBy, CreatedAt, LastUpdatedBy, LastUpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM ContractTemplate
    WHERE ContractName = @ContractName AND IsDeleted = 0;
END;

CREATE PROCEDURE uspContractTemplateDelete
    @ContractTemplateID INT,
    @DeletedBy INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE ContractTemplate
    SET IsDeleted = 1, DeletedAt = GETUTCDATE(), DeletedBy = @DeletedBy, LastUpdatedAt = GETUTCDATE()
    WHERE ContractTemplateID = @ContractTemplateID AND IsDeleted = 0;

    SELECT @ContractTemplateID AS ContractTemplateID;
END;

-- ============================================
-- PRICING RULE PROCEDURES (Gap #20)
-- ============================================

CREATE PROCEDURE uspPricingRuleUpsert
    @Id INT = 0,
    @RuleName NVARCHAR(255),
    @ServiceCategory NVARCHAR(100) = NULL,
    @RuleType NVARCHAR(50),
    @AdjustmentType NVARCHAR(50),
    @AdjustmentValue DECIMAL(10,2),
    @EffectiveFrom DATETIME = NULL,
    @EffectiveTo DATETIME = NULL,
    @IsActive BIT = 1,
    @CreatedBy INT,
    @UpdatedBy INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Id = 0
        BEGIN
            INSERT INTO PricingRule (
                RuleName, ServiceCategory, RuleType, AdjustmentType, AdjustmentValue,
                EffectiveFrom, EffectiveTo, IsActive, CreatedBy, UpdatedBy, CreatedAt, UpdatedAt
            ) VALUES (
                @RuleName, @ServiceCategory, @RuleType, @AdjustmentType, @AdjustmentValue,
                @EffectiveFrom, @EffectiveTo, @IsActive, @CreatedBy, @CreatedBy, GETUTCDATE(), GETUTCDATE()
            );

            SELECT CAST(SCOPE_IDENTITY() AS INT) AS PricingRuleID;
        END
        ELSE
        BEGIN
            UPDATE PricingRule
            SET RuleName = @RuleName,
                ServiceCategory = @ServiceCategory,
                RuleType = @RuleType,
                AdjustmentType = @AdjustmentType,
                AdjustmentValue = @AdjustmentValue,
                EffectiveFrom = @EffectiveFrom,
                EffectiveTo = @EffectiveTo,
                IsActive = @IsActive,
                UpdatedBy = @UpdatedBy,
                UpdatedAt = GETUTCDATE()
            WHERE PricingRuleID = @Id AND IsDeleted = 0;

            SELECT @Id AS PricingRuleID;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;

CREATE PROCEDURE uspPricingRuleRead
    @PricingRuleID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        PricingRuleID, RuleName, ServiceCategory, RuleType, AdjustmentType, AdjustmentValue,
        EffectiveFrom, EffectiveTo, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt,
        DeletedBy, DeletedAt, IsDeleted
    FROM PricingRule
    WHERE PricingRuleID = @PricingRuleID AND IsDeleted = 0;
END;

CREATE PROCEDURE uspPricingRuleReadAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        PricingRuleID, RuleName, ServiceCategory, RuleType, AdjustmentType, AdjustmentValue,
        EffectiveFrom, EffectiveTo, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt,
        DeletedBy, DeletedAt, IsDeleted
    FROM PricingRule
    WHERE IsDeleted = 0
    ORDER BY RuleName ASC;
END;

CREATE PROCEDURE uspPricingRuleReadPaged
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @ServiceCategory NVARCHAR(100) = NULL,
    @RuleType NVARCHAR(50) = NULL,
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    SELECT
        PricingRuleID, RuleName, ServiceCategory, RuleType, AdjustmentType, AdjustmentValue,
        EffectiveFrom, EffectiveTo, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt,
        DeletedBy, DeletedAt, IsDeleted
    FROM PricingRule
    WHERE IsDeleted = 0
        AND (@ServiceCategory IS NULL OR ServiceCategory = @ServiceCategory)
        AND (@RuleType IS NULL OR RuleType = @RuleType)
        AND (@IsActive IS NULL OR IsActive = @IsActive)
    ORDER BY RuleName ASC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;

CREATE PROCEDURE uspPricingRuleGetByRuleType
    @RuleType NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        PricingRuleID, RuleName, ServiceCategory, RuleType, AdjustmentType, AdjustmentValue,
        EffectiveFrom, EffectiveTo, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt,
        DeletedBy, DeletedAt, IsDeleted
    FROM PricingRule
    WHERE RuleType = @RuleType AND IsActive = 1 AND IsDeleted = 0
    ORDER BY RuleName ASC;
END;

CREATE PROCEDURE uspPricingRuleGetByServiceCategory
    @ServiceCategory NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        PricingRuleID, RuleName, ServiceCategory, RuleType, AdjustmentType, AdjustmentValue,
        EffectiveFrom, EffectiveTo, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt,
        DeletedBy, DeletedAt, IsDeleted
    FROM PricingRule
    WHERE ServiceCategory = @ServiceCategory AND IsActive = 1 AND IsDeleted = 0
    ORDER BY RuleName ASC;
END;

CREATE PROCEDURE uspPricingRuleGetActiveOnDate
    @Date DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        PricingRuleID, RuleName, ServiceCategory, RuleType, AdjustmentType, AdjustmentValue,
        EffectiveFrom, EffectiveTo, IsActive, CreatedBy, CreatedAt, UpdatedBy, UpdatedAt,
        DeletedBy, DeletedAt, IsDeleted
    FROM PricingRule
    WHERE IsActive = 1 AND IsDeleted = 0
        AND (EffectiveFrom IS NULL OR @Date >= EffectiveFrom)
        AND (EffectiveTo IS NULL OR @Date <= EffectiveTo)
    ORDER BY RuleName ASC;
END;

CREATE PROCEDURE uspPricingRuleDelete
    @PricingRuleID INT,
    @DeletedBy INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE PricingRule
    SET IsDeleted = 1, DeletedAt = GETUTCDATE(), DeletedBy = @DeletedBy
    WHERE PricingRuleID = @PricingRuleID AND IsDeleted = 0;

    SELECT @PricingRuleID AS PricingRuleID;
END;

-- ============================================
-- DELIVERY PACKAGE PROCEDURES (Gap #25)
-- ============================================

CREATE PROCEDURE uspDeliveryPackageUpsert
    @Id INT = 0,
    @BookingID INT,
    @DeliverableType NVARCHAR(100),
    @DeliveryDate DATETIME = NULL,
    @DeliveryMethod NVARCHAR(50),
    @DeliveryNotes NVARCHAR(MAX) = NULL,
    @IsCompleted BIT = 0,
    @CompletedAt DATETIME = NULL,
    @CreatedBy INT,
    @UpdatedBy INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Id = 0
        INSERT INTO DeliveryPackage
            (BookingID, DeliverableType, DeliveryDate, DeliveryMethod, DeliveryNotes, IsCompleted, CompletedAt, CreatedBy, CreatedAt, UpdatedAt)
        VALUES
            (@BookingID, @DeliverableType, @DeliveryDate, @DeliveryMethod, @DeliveryNotes, @IsCompleted, @CompletedAt, @CreatedBy, GETUTCDATE(), GETUTCDATE());
    ELSE
        UPDATE DeliveryPackage
        SET BookingID = @BookingID,
            DeliverableType = @DeliverableType,
            DeliveryDate = @DeliveryDate,
            DeliveryMethod = @DeliveryMethod,
            DeliveryNotes = @DeliveryNotes,
            IsCompleted = @IsCompleted,
            CompletedAt = @CompletedAt,
            UpdatedBy = @UpdatedBy,
            UpdatedAt = GETUTCDATE()
        WHERE DeliveryPackageID = @Id AND IsDeleted = 0;

    SELECT @@IDENTITY AS DeliveryPackageID;
END;

CREATE PROCEDURE uspDeliveryPackageRead
    @DeliveryPackageID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        DeliveryPackageID, BookingID, DeliverableType, DeliveryDate, DeliveryMethod,
        DeliveryNotes, IsCompleted, CompletedAt, CreatedBy, CreatedAt, UpdatedBy,
        UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM DeliveryPackage
    WHERE DeliveryPackageID = @DeliveryPackageID AND IsDeleted = 0;
END;

CREATE PROCEDURE uspDeliveryPackageReadAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        DeliveryPackageID, BookingID, DeliverableType, DeliveryDate, DeliveryMethod,
        DeliveryNotes, IsCompleted, CompletedAt, CreatedBy, CreatedAt, UpdatedBy,
        UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM DeliveryPackage
    WHERE IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE PROCEDURE uspDeliveryPackageReadPaged
    @PageNumber INT = 1,
    @PageSize INT = 10,
    @BookingID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OffSet INT = (@PageNumber - 1) * @PageSize;

    SELECT
        DeliveryPackageID, BookingID, DeliverableType, DeliveryDate, DeliveryMethod,
        DeliveryNotes, IsCompleted, CompletedAt, CreatedBy, CreatedAt, UpdatedBy,
        UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM DeliveryPackage
    WHERE IsDeleted = 0
        AND (@BookingID IS NULL OR BookingID = @BookingID)
    ORDER BY CreatedAt DESC
    OFFSET @OffSet ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;

CREATE PROCEDURE uspDeliveryPackageGetByBooking
    @BookingID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        DeliveryPackageID, BookingID, DeliverableType, DeliveryDate, DeliveryMethod,
        DeliveryNotes, IsCompleted, CompletedAt, CreatedBy, CreatedAt, UpdatedBy,
        UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM DeliveryPackage
    WHERE BookingID = @BookingID AND IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE PROCEDURE uspDeliveryPackageGetPending
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        DeliveryPackageID, BookingID, DeliverableType, DeliveryDate, DeliveryMethod,
        DeliveryNotes, IsCompleted, CompletedAt, CreatedBy, CreatedAt, UpdatedBy,
        UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM DeliveryPackage
    WHERE IsCompleted = 0 AND IsDeleted = 0
    ORDER BY DeliveryDate ASC, CreatedAt DESC;
END;

CREATE PROCEDURE uspDeliveryPackageGetByType
    @DeliverableType NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        DeliveryPackageID, BookingID, DeliverableType, DeliveryDate, DeliveryMethod,
        DeliveryNotes, IsCompleted, CompletedAt, CreatedBy, CreatedAt, UpdatedBy,
        UpdatedAt, DeletedBy, DeletedAt, IsDeleted
    FROM DeliveryPackage
    WHERE DeliverableType = @DeliverableType AND IsDeleted = 0
    ORDER BY CreatedAt DESC;
END;

CREATE PROCEDURE uspDeliveryPackageDelete
    @DeliveryPackageID INT,
    @DeletedBy INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE DeliveryPackage
    SET IsDeleted = 1, DeletedAt = GETUTCDATE(), DeletedBy = @DeletedBy
    WHERE DeliveryPackageID = @DeliveryPackageID AND IsDeleted = 0;

    SELECT @DeliveryPackageID AS DeliveryPackageID;
END;


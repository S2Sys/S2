# SmartWorkz.S2 Clean Architecture Design

**Date:** 2026-04-26  
**Project:** SmartWorkz.S2.slx  
**Tech Stack:** .NET Core 10, Dapper, SQL Server, JWT + RBAC  
**Status:** Approved

---

## 1. Overview

**SmartWorkz.S2** is a single REST API serving both public and admin dashboards with a clean, layered architecture. The system manages users, projects, tasks, teams, roles, and permissions using traditional Clean Architecture patterns with Dapper as the micro-ORM.

**Key Characteristics:**
- Single API with dual endpoint scopes (`/api/` for public, `/api/admin/` for admin)
- Four-layer clean architecture (API, Application, Domain, Infrastructure)
- Flat namespace structure (no folder nesting)
- Stored Procedures for all data access
- JWT token-based authentication with Role-Based Access Control (RBAC)
- Generic pagination and lookup patterns
- Async/await throughout
- Comprehensive test coverage (unit + integration)

---

## 2. Project Structure

### Solution Layout

```
SmartWorkz.S2.sln
├── SmartWorkz.S2.Api/               (HTTP Entry Points - Single API)
├── SmartWorkz.S2.Application/       (Use Cases & Business Orchestration - SHARED)
├── SmartWorkz.S2.Domain/            (Entities & Interfaces - SHARED)
├── SmartWorkz.S2.Infrastructure/    (Dapper Repositories & DB - SHARED)
├── SmartWorkz.S2.Database/          (Stored Procedures & Migrations)
└── SmartWorkz.S2.Tests/             (Unit & Integration Tests)
```

### Flat Namespace Convention

All files live in the project root directory without subfolder nesting for namespaces. Namespaces follow this pattern:

- **API Layer:** `SmartWorkz.S2.Api`
- **Application Layer:** `SmartWorkz.S2.Application`
- **Domain Layer:** `SmartWorkz.S2.Domain`
- **Infrastructure Layer:** `SmartWorkz.S2.Infrastructure`
- **Tests:** `SmartWorkz.S2.Tests`

Example files:
- `SmartWorkz.S2.Api/UserController.cs` → `namespace SmartWorkz.S2.Api;`
- `SmartWorkz.S2.Application/CreateUserUseCase.cs` → `namespace SmartWorkz.S2.Application;`
- `SmartWorkz.S2.Domain/User.cs` → `namespace SmartWorkz.S2.Domain;`
- `SmartWorkz.S2.Infrastructure/UserRepository.cs` → `namespace SmartWorkz.S2.Infrastructure;`

---

## 3. Architecture Layers

### 3.1 Domain Layer (`SmartWorkz.S2.Domain`)

**Responsibility:** Core business logic, entities, value objects, and repository interfaces.

**Contains:**
- **Entities:** `User`, `Project`, `Task`, `Team`, `Role`, `Permission`
- **Repository Interfaces:** `IUserRepository`, `IProjectRepository`, `ITaskRepository`, `ITeamRepository`, `IRoleRepository`, `IPermissionRepository`
- **Common Interfaces:** `ILookupResult<T>`, `IPagedResult<T>`, `IPaginationParams`, `IAuthService`
- **Custom Exceptions:** Domain-specific exceptions extending `DomainException`
- **Value Objects:** Reusable domain concepts (if needed)

**Dependencies:** None (core domain has zero external dependencies)

**Example:**
```csharp
namespace SmartWorkz.S2.Domain;

public class User
{
    public int Id { get; set; }
    public string Email { get; set; }
    public string Name { get; set; }
    public string PasswordHash { get; set; }
    public DateTime CreatedAt { get; set; }
}

public interface IUserRepository
{
    Task<User> GetByIdAsync(int id);
    Task<IPagedResult<User>> GetAllAsync(int pageNumber, int pageSize);
    Task<IEnumerable<Lookup<int>>> GetLookupsAsync();
    Task<int> UpsertAsync(User user);
    Task DeleteAsync(int id);
}
```

---

### 3.2 Application Layer (`SmartWorkz.S2.Application`)

**Responsibility:** Use cases, business orchestration, DTOs, and application services.

**Contains:**
- **Use Cases:** One use case per action (e.g., `CreateUserUseCase`, `UpdateProjectUseCase`)
- **DTOs:** Request and response data transfer objects
- **Application Services:** Coordinating domain logic and repositories
- **Validation:** Input validation logic
- **Mapping:** DTO ↔ Domain entity mapping

**Dependencies:** Domain layer only

**Example:**
```csharp
namespace SmartWorkz.S2.Application;

public class CreateUserDto
{
    public string Email { get; set; }
    public string Name { get; set; }
    public string Password { get; set; }
}

public class UserDto
{
    public int Id { get; set; }
    public string Email { get; set; }
    public string Name { get; set; }
    public string RoleName { get; set; }
    public DateTime CreatedAt { get; set; }
}

public interface ICreateUserUseCase
{
    Task<UserDto> ExecuteAsync(CreateUserDto dto);
}

public class CreateUserUseCase : ICreateUserUseCase
{
    private readonly IUserRepository _userRepository;

    public CreateUserUseCase(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }

    public async Task<UserDto> ExecuteAsync(CreateUserDto dto)
    {
        // Validate
        if (string.IsNullOrWhiteSpace(dto.Email))
            throw new ValidationException(new { Email = new[] { "Email is required" } });

        // Create domain entity
        var user = new User
        {
            Email = dto.Email,
            Name = dto.Name,
            PasswordHash = HashPassword(dto.Password),
            CreatedAt = DateTime.UtcNow
        };

        // Persist
        var userId = await _userRepository.UpsertAsync(user);

        // Return DTO
        var created = await _userRepository.GetByIdAsync(userId);
        return MapToDto(created);
    }

    private string HashPassword(string password) => 
        BCrypt.Net.BCrypt.HashPassword(password);

    private UserDto MapToDto(User user) => 
        new UserDto 
        { 
            Id = user.Id, 
            Email = user.Email, 
            Name = user.Name, 
            CreatedAt = user.CreatedAt 
        };
}
```

---

### 3.3 Infrastructure Layer (`SmartWorkz.S2.Infrastructure`)

**Responsibility:** Data access via Dapper, database connectivity, external service integrations.

**Contains:**
- **Repositories:** Implementation of domain repository interfaces using Dapper
- **Database Connection:** Connection management and SP execution
- **Mappers:** SQL result → domain entity mapping
- **External Services:** Third-party integrations (email, notifications, etc.)

**Dependencies:** Domain layer only

**Key Principles:**
- All data access via **Stored Procedures** (no raw SQL queries in code)
- **UPSERT pattern** for create/update operations
- **Dapper query execution** with async/await
- No N+1 queries; explicit load when relationships needed

**Example:**
```csharp
namespace SmartWorkz.S2.Infrastructure;

public class UserRepository : IUserRepository
{
    private readonly DatabaseConnection _connection;

    public UserRepository(DatabaseConnection connection)
    {
        _connection = connection;
    }

    public async Task<User> GetByIdAsync(int id)
    {
        return await _connection.QuerySingleOrDefaultAsync<User>(
            "usp_User_GetById",
            new { UserId = id },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<IPagedResult<User>> GetAllAsync(int pageNumber, int pageSize)
    {
        var totalCount = await _connection.QuerySingleAsync<int>(
            "usp_User_GetCount",
            commandType: CommandType.StoredProcedure
        );

        var items = await _connection.QueryAsync<User>(
            "usp_User_GetPaged",
            new { PageNumber = pageNumber, PageSize = pageSize },
            commandType: CommandType.StoredProcedure
        );

        return new PagedResult<User>
        {
            Items = items,
            TotalCount = totalCount,
            PageNumber = pageNumber,
            PageSize = pageSize
        };
    }

    public async Task<IEnumerable<Lookup<int>>> GetLookupsAsync()
    {
        return await _connection.QueryAsync<Lookup<int>>(
            "usp_User_GetLookups",
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<int> UpsertAsync(User user)
    {
        return await _connection.ExecuteScalarAsync<int>(
            "usp_User_Upsert",
            new
            {
                user.Id,
                user.Email,
                user.Name,
                user.PasswordHash,
                user.CreatedAt
            },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task DeleteAsync(int id)
    {
        await _connection.ExecuteAsync(
            "usp_User_Delete",
            new { UserId = id },
            commandType: CommandType.StoredProcedure
        );
    }
}

public class DatabaseConnection
{
    private readonly string _connectionString;

    public DatabaseConnection(string connectionString)
    {
        _connectionString = connectionString;
    }

    public async Task<T> QuerySingleOrDefaultAsync<T>(
        string spName,
        object parameters = null,
        CommandType commandType = CommandType.StoredProcedure)
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QuerySingleOrDefaultAsync<T>(
            spName,
            parameters,
            commandType: commandType
        );
    }

    public async Task<IEnumerable<T>> QueryAsync<T>(
        string spName,
        object parameters = null,
        CommandType commandType = CommandType.StoredProcedure)
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.QueryAsync<T>(
            spName,
            parameters,
            commandType: commandType
        );
    }

    public async Task<T> ExecuteScalarAsync<T>(
        string spName,
        object parameters = null,
        CommandType commandType = CommandType.StoredProcedure)
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.ExecuteScalarAsync<T>(
            spName,
            parameters,
            commandType: commandType
        );
    }

    public async Task<int> ExecuteAsync(
        string spName,
        object parameters = null,
        CommandType commandType = CommandType.StoredProcedure)
    {
        using var connection = new SqlConnection(_connectionString);
        return await connection.ExecuteAsync(
            spName,
            parameters,
            commandType: commandType
        );
    }
}
```

---

### 3.4 API Layer (`SmartWorkz.S2.Api`)

**Responsibility:** HTTP endpoints, middleware, routing, request/response handling.

**Contains:**
- **Controllers:** REST endpoints grouped by resource
  - Public routes: `/api/users`, `/api/projects`, `/api/tasks`
  - Admin routes: `/api/admin/users`, `/api/admin/teams`, `/api/admin/roles`
- **Middleware:** Authentication, authorization, exception handling
- **Program.cs:** Dependency injection wiring, middleware setup
- **Filters & Attributes:** Cross-cutting concerns (validation, logging)

**Dependencies:** Application layer

**Endpoint Structure:**
```csharp
namespace SmartWorkz.S2.Api;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class UserController : ControllerBase
{
    private readonly ICreateUserUseCase _createUserUseCase;
    private readonly IGetUserUseCase _getUserUseCase;
    private readonly IGetAllUsersUseCase _getAllUsersUseCase;

    public UserController(
        ICreateUserUseCase createUserUseCase,
        IGetUserUseCase getUserUseCase,
        IGetAllUsersUseCase getAllUsersUseCase)
    {
        _createUserUseCase = createUserUseCase;
        _getUserUseCase = getUserUseCase;
        _getAllUsersUseCase = getAllUsersUseCase;
    }

    [HttpGet("{id}")]
    [Authorize(Roles = "User,Admin")]
    public async Task<IActionResult> GetById(int id)
    {
        var result = await _getUserUseCase.ExecuteAsync(id);
        return Ok(result);
    }

    [HttpGet]
    [Authorize(Roles = "User,Admin")]
    public async Task<IActionResult> GetAll([FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 10)
    {
        var result = await _getAllUsersUseCase.ExecuteAsync(pageNumber, pageSize);
        return Ok(result);
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> Create([FromBody] CreateUserDto dto)
    {
        var result = await _createUserUseCase.ExecuteAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }
}

[ApiController]
[Route("api/admin/[controller]")]
[Authorize(Roles = "Admin")]
public class AdminUserController : ControllerBase
{
    private readonly IUpdateUserUseCase _updateUserUseCase;
    private readonly IDeleteUserUseCase _deleteUserUseCase;

    public AdminUserController(
        IUpdateUserUseCase updateUserUseCase,
        IDeleteUserUseCase deleteUserUseCase)
    {
        _updateUserUseCase = updateUserUseCase;
        _deleteUserUseCase = deleteUserUseCase;
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateUserDto dto)
    {
        await _updateUserUseCase.ExecuteAsync(id, dto);
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        await _deleteUserUseCase.ExecuteAsync(id);
        return NoContent();
    }
}
```

---

## 4. Data Access Patterns

### 4.1 Repository Pattern

**One repository per aggregate:**
- `IUserRepository` / `UserRepository`
- `IProjectRepository` / `ProjectRepository`
- `ITaskRepository` / `TaskRepository`
- `ITeamRepository` / `TeamRepository`
- `IRoleRepository` / `RoleRepository`
- `IPermissionRepository` / `PermissionRepository`

### 4.2 Generic Lookup Pattern

**For dropdowns and select lists:**

```csharp
namespace SmartWorkz.S2.Domain;

public interface ILookupResult<T>
{
    T Id { get; }
    string Name { get; }
    bool IsSelected { get; set; }
}

public class Lookup<T> : ILookupResult<T>
{
    public T Id { get; set; }
    public string Name { get; set; }
    public bool IsSelected { get; set; }
}
```

**Usage:** `Task<IEnumerable<Lookup<int>>> GetLookupsAsync();`

**Example SQL:**
```sql
CREATE PROCEDURE usp_User_GetLookups
    @SelectedUserIds NVARCHAR(MAX) = NULL
AS
BEGIN
    SELECT 
        Id,
        Name,
        CASE WHEN @SelectedUserIds LIKE '%,' + CAST(Id AS NVARCHAR) + ',%' 
             THEN 1 ELSE 0 END AS IsSelected
    FROM Users 
    ORDER BY Name
END
```

### 4.3 Pagination Pattern

**Interface:**
```csharp
namespace SmartWorkz.S2.Domain;

public interface IPagedResult<T>
{
    IEnumerable<T> Items { get; }
    int TotalCount { get; }
    int PageNumber { get; }
    int PageSize { get; }
    int TotalPages { get; }
    bool HasNextPage { get; }
    bool HasPreviousPage { get; }
}

public class PagedResult<T> : IPagedResult<T>
{
    public IEnumerable<T> Items { get; set; }
    public int TotalCount { get; set; }
    public int PageNumber { get; set; }
    public int PageSize { get; set; }
    public int TotalPages => (TotalCount + PageSize - 1) / PageSize;
    public bool HasNextPage => PageNumber < TotalPages;
    public bool HasPreviousPage => PageNumber > 1;
}
```

**Usage:** `Task<IPagedResult<User>> GetAllAsync(int pageNumber, int pageSize);`

### 4.4 Stored Procedure Pattern

**All data access via SPs—no raw SQL in code.**

**UPSERT SP (insert or update):**
```sql
CREATE PROCEDURE usp_User_Upsert
    @Id INT = 0,
    @Email NVARCHAR(255),
    @Name NVARCHAR(255),
    @PasswordHash NVARCHAR(MAX),
    @CreatedAt DATETIME
AS
BEGIN
    IF @Id = 0
        INSERT INTO Users (Email, Name, PasswordHash, CreatedAt)
        VALUES (@Email, @Name, @PasswordHash, @CreatedAt)
        SELECT CAST(SCOPE_IDENTITY() AS INT)
    ELSE
        UPDATE Users SET Email = @Email, Name = @Name, PasswordHash = @PasswordHash
        WHERE Id = @Id
        SELECT @Id
END
```

**Read SP (single):**
```sql
CREATE PROCEDURE usp_User_GetById
    @UserId INT
AS
BEGIN
    SELECT * FROM Users WHERE Id = @UserId
END
```

**Count SP:**
```sql
CREATE PROCEDURE usp_User_GetCount
AS
BEGIN
    SELECT COUNT(*) FROM Users
END
```

**Paged SP:**
```sql
CREATE PROCEDURE usp_User_GetPaged
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SELECT * FROM Users
    ORDER BY Id
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY
END
```

---

## 5. Authentication & Authorization

### 5.1 JWT Token Flow

1. Client sends credentials to `/api/auth/login`
2. Server validates email/password, creates JWT token
3. Client includes token in `Authorization: Bearer <token>` header
4. Server validates token signature and expiration in middleware
5. User principal populated from JWT claims
6. RBAC checks enforce endpoint access

### 5.2 RBAC (Role-Based Access Control)

**Roles:** Admin, User  
**Permissions:** Managed per role via `RolePermissions` join table

**Endpoint Authorization:**
```csharp
[Authorize(Roles = "Admin")]              // Admin only
[Authorize(Roles = "User,Admin")]         // User or Admin
[Authorize]                               // Any authenticated user
```

### 5.3 Authentication Middleware

```csharp
namespace SmartWorkz.S2.Api;

public class AuthMiddleware
{
    private readonly RequestDelegate _next;

    public AuthMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context, IAuthService authService)
    {
        var token = context.Request.Headers["Authorization"]
            .ToString()
            .Replace("Bearer ", "");

        if (!string.IsNullOrEmpty(token))
        {
            try
            {
                var principal = ValidateJwtToken(token);
                context.User = principal;
            }
            catch
            {
                context.Response.StatusCode = 401;
                return;
            }
        }

        await _next(context);
    }

    private ClaimsPrincipal ValidateJwtToken(string token)
    {
        // JWT validation logic
        throw new NotImplementedException();
    }
}
```

---

## 6. Error Handling

### 6.1 Custom Exceptions

```csharp
namespace SmartWorkz.S2.Domain;

public abstract class DomainException : Exception
{
    public string Code { get; protected set; }
    public int StatusCode { get; protected set; } = 400;

    public DomainException(string message, string code = "DOMAIN_ERROR")
        : base(message)
    {
        Code = code;
    }
}

public class EntityNotFoundException : DomainException
{
    public EntityNotFoundException(string entityName, int id)
        : base($"{entityName} with ID {id} not found", "ENTITY_NOT_FOUND")
    {
        StatusCode = 404;
    }
}

public class UnauthorizedException : DomainException
{
    public UnauthorizedException(string message = "Unauthorized")
        : base(message, "UNAUTHORIZED")
    {
        StatusCode = 403;
    }
}

public class ValidationException : DomainException
{
    public Dictionary<string, string[]> Errors { get; set; }

    public ValidationException(Dictionary<string, string[]> errors)
        : base("Validation failed", "VALIDATION_ERROR")
    {
        Errors = errors;
        StatusCode = 400;
    }
}
```

### 6.2 Global Exception Handler Middleware

```csharp
namespace SmartWorkz.S2.Api;

public class GlobalExceptionHandler
{
    private readonly RequestDelegate _next;

    public GlobalExceptionHandler(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            await HandleExceptionAsync(context, ex);
        }
    }

    private static Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        context.Response.ContentType = "application/json";

        if (exception is DomainException domainEx)
        {
            context.Response.StatusCode = domainEx.StatusCode;
            return context.Response.WriteAsJsonAsync(new
            {
                code = domainEx.Code,
                message = domainEx.Message,
                statusCode = domainEx.StatusCode
            });
        }

        if (exception is ValidationException validationEx)
        {
            context.Response.StatusCode = 400;
            return context.Response.WriteAsJsonAsync(new
            {
                code = validationEx.Code,
                message = validationEx.Message,
                errors = validationEx.Errors,
                statusCode = 400
            });
        }

        context.Response.StatusCode = 500;
        return context.Response.WriteAsJsonAsync(new
        {
            code = "INTERNAL_ERROR",
            message = "An internal error occurred",
            statusCode = 500
        });
    }
}
```

---

## 7. Testing Strategy

### 7.1 Unit Tests (Use Case Layer)

**Pattern:** Mock repositories, test business logic in isolation

```csharp
namespace SmartWorkz.S2.Tests;

public class CreateUserUseCaseTests
{
    private readonly Mock<IUserRepository> _userRepositoryMock;
    private readonly CreateUserUseCase _useCase;

    public CreateUserUseCaseTests()
    {
        _userRepositoryMock = new Mock<IUserRepository>();
        _useCase = new CreateUserUseCase(_userRepositoryMock.Object);
    }

    [Fact]
    public async Task ExecuteAsync_WithValidEmail_ReturnsUserId()
    {
        // Arrange
        var dto = new CreateUserDto { Email = "test@example.com", Name = "Test" };
        _userRepositoryMock.Setup(x => x.UpsertAsync(It.IsAny<User>()))
            .ReturnsAsync(1);

        // Act
        var result = await _useCase.ExecuteAsync(dto);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(1, result.Id);
        _userRepositoryMock.Verify(x => x.UpsertAsync(It.IsAny<User>()), Times.Once);
    }
}
```

### 7.2 Integration Tests (Repository Layer)

**Pattern:** Real database connection, test SP correctness

```csharp
namespace SmartWorkz.S2.Tests;

public class UserRepositoryIntegrationTests : IAsyncLifetime
{
    private readonly DatabaseConnection _connection;
    private readonly UserRepository _repository;

    public async Task InitializeAsync()
    {
        _connection = new DatabaseConnection("TestConnectionString");
        _repository = new UserRepository(_connection);
        await _connection.ExecuteAsync(
            "usp_ClearTestData",
            commandType: CommandType.StoredProcedure
        );
    }

    public Task DisposeAsync() => Task.CompletedTask;

    [Fact]
    public async Task UpsertAsync_WithNewUser_InsertsAndReturnsId()
    {
        // Arrange
        var user = new User { Email = "new@example.com", Name = "New User" };

        // Act
        var result = await _repository.UpsertAsync(user);

        // Assert
        Assert.True(result > 0);
        var retrieved = await _repository.GetByIdAsync(result);
        Assert.NotNull(retrieved);
        Assert.Equal("new@example.com", retrieved.Email);
    }

    [Fact]
    public async Task UpsertAsync_WithExistingUser_Updates()
    {
        // Arrange
        var user = new User { Id = 1, Email = "update@example.com", Name = "Updated" };

        // Act
        var result = await _repository.UpsertAsync(user);

        // Assert
        Assert.Equal(1, result);
        var retrieved = await _repository.GetByIdAsync(1);
        Assert.Equal("update@example.com", retrieved.Email);
    }
}
```

---

## 8. Dependency Injection (Program.cs)

```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddScoped<DatabaseConnection>(sp =>
    new DatabaseConnection(builder.Configuration.GetConnectionString("DefaultConnection")));

// Repositories
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IProjectRepository, ProjectRepository>();
builder.Services.AddScoped<ITaskRepository, TaskRepository>();
builder.Services.AddScoped<ITeamRepository, TeamRepository>();
builder.Services.AddScoped<IRoleRepository, RoleRepository>();
builder.Services.AddScoped<IPermissionRepository, PermissionRepository>();

// Use Cases
builder.Services.AddScoped<ICreateUserUseCase, CreateUserUseCase>();
builder.Services.AddScoped<IGetUserUseCase, GetUserUseCase>();
builder.Services.AddScoped<IGetAllUsersUseCase, GetAllUsersUseCase>();
builder.Services.AddScoped<IUpdateUserUseCase, UpdateUserUseCase>();
builder.Services.AddScoped<IDeleteUserUseCase, DeleteUserUseCase>();

// Auth
builder.Services.AddScoped<IAuthService, AuthService>();

// Controllers
builder.Services.AddControllers();

var app = builder.Build();

// Middleware
app.UseMiddleware<GlobalExceptionHandler>();
app.UseMiddleware<AuthMiddleware>();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

---

## 9. Technology Stack

- **.NET Core 10** - Latest runtime
- **Dapper** - Lightweight micro-ORM
- **SQL Server** - Relational database
- **JWT (HS256)** - Token-based authentication
- **BCrypt.Net** - Password hashing
- **xUnit** - Unit testing framework
- **Moq** - Mocking library
- **Swagger/OpenAPI** - API documentation

---

## 10. Key Architecture Decisions

| Decision | Rationale |
|----------|-----------|
| **Single API** | Unified entry point for both public and admin dashboards; RBAC enforces separation |
| **Flat Namespaces** | Simplifies navigation; reduces cognitive load; improves discoverability |
| **Stored Procedures** | Centralized business logic, easier to audit, performance optimization, security |
| **UPSERT Pattern** | Single operation for create/update; reduces code duplication; atomic |
| **Generic Lookups** | Reusable across all entities; supports pre-selection for forms |
| **Pagination** | Scalable data retrieval; metadata for UI pagination controls |
| **JWT + RBAC** | Stateless auth; scales horizontally; fine-grained access control |
| **Async/Await** | Non-blocking I/O; scales for concurrent requests; .NET best practice |
| **Custom Exceptions** | Consistent error handling; semantic error codes; easy to test |
| **Global Handler** | Centralized error transformation; consistent API error format |

---

## 11. Future Considerations

- **Audit Logging:** Add created_by, modified_by, created_at, modified_at to all entities
- **Soft Deletes:** Use IsDeleted flag instead of hard deletes for data retention
- **Caching:** Redis for frequently accessed lookups
- **Rate Limiting:** Protect endpoints from abuse
- **API Versioning:** Support multiple API versions if needed
- **GraphQL Alternative:** Consider if complex query needs arise

---

## 12. Acceptance Criteria

✅ Project structure matches design  
✅ All data access via Stored Procedures  
✅ Flat namespaces (no folder nesting)  
✅ Generic Lookup<T> pattern for dropdowns  
✅ Pagination with IPagedResult<T>  
✅ UPSERT for all create/update operations  
✅ JWT authentication with RBAC  
✅ Global exception handler  
✅ Unit tests (mocked repositories)  
✅ Integration tests (real database)  
✅ Dependency injection in Program.cs  
✅ Controllers use dependency injection  

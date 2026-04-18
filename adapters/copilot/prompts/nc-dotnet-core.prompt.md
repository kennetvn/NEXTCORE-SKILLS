---
description: .NET backend with ASP.NET Core, EF Core, C#. Use when building Microsoft-stack APIs, evaluating .NET vs Java/Node, migrating legacy .NET Framework, or enterprise Microsoft environments.
mode: agent
---

# .NET Core / ASP.NET Core

## When .NET

- Enterprise Microsoft ecosystem (Azure, SQL Server, Active Directory)
- Team has C# expertise
- Large-scale, long-lived (Microsoft's LTS support)
- Need performance + strong typing

## Minimal API (lightweight, 2026 default)

```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddDbContext<AppDb>(o => o.UseNpgsql("..."));
var app = builder.Build();

app.MapGet("/users/{id}", async (int id, AppDb db) =>
{
    var user = await db.Users.FindAsync(id);
    return user is null ? Results.NotFound() : Results.Ok(user);
});

app.MapPost("/users", async (CreateUserDto dto, AppDb db) =>
{
    var user = new User { Email = dto.Email };
    db.Users.Add(user);
    await db.SaveChangesAsync();
    return Results.Created($"/users/{user.Id}", user);
});

app.Run();
```

## Controllers (when complexity warrants)

```csharp
[ApiController]
[Route("api/[controller]")]
public class UsersController(AppDb db) : ControllerBase
{
    [HttpGet("{id}")]
    public async Task<ActionResult<User>> Get(int id)
    {
        var user = await db.Users.FindAsync(id);
        return user is null ? NotFound() : Ok(user);
    }
}
```

## EF Core (ORM)

```csharp
public class User
{
    public int Id { get; set; }
    public required string Email { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

public class AppDb(DbContextOptions<AppDb> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();

    protected override void OnModelCreating(ModelBuilder b)
    {
        b.Entity<User>(e =>
        {
            e.Property(u => u.Email).HasMaxLength(255);
            e.HasIndex(u => u.Email).IsUnique();
        });
    }
}
```

### Migrations

```bash
dotnet ef migrations add AddUsers
dotnet ef database update
```

## Authentication (JWT)

```csharp
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new()
        {
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
        };
    });

app.MapGet("/protected", () => "Secret").RequireAuthorization();
```

## Dependency injection (built-in)

```csharp
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddSingleton<IEmailService, SendGridEmailService>();
builder.Services.AddHttpClient<IApiClient, ApiClient>();

// Inject in minimal API
app.MapGet("/users", (IUserService svc) => svc.ListAsync());
```

## Validation (FluentValidation or DataAnnotations)

```csharp
public class CreateUserValidator : AbstractValidator<CreateUserDto>
{
    public CreateUserValidator()
    {
        RuleFor(x => x.Email).NotEmpty().EmailAddress();
        RuleFor(x => x.Password).MinimumLength(8);
    }
}
```

## Background services

```csharp
public class CleanupService : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            await cleanupExpired();
            await Task.Delay(TimeSpan.FromHours(1), ct);
        }
    }
}

builder.Services.AddHostedService<CleanupService>();
```

## Testing

```csharp
public class UsersApiTests(WebApplicationFactory<Program> factory) : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client = factory.CreateClient();

    [Fact]
    public async Task GetUser_ReturnsOk()
    {
        var response = await _client.GetAsync("/users/1");
        response.StatusCode.ShouldBe(HttpStatusCode.OK);
    }
}
```

Run: `dotnet test`

## Deploy

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /out

FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY --from=build /out .
EXPOSE 8080
ENTRYPOINT ["dotnet", "MyApp.dll"]
```

Deploy options: Azure App Service, AWS ECS, Kubernetes, Railway.

## Anti-patterns

- Blocking `.Result` / `.Wait()` instead of `await` (deadlock)
- Over-using `async void` (exceptions crash process)
- Not using `IDisposable` / `using` for DbContext
- `DbContext` as singleton (it's scoped for thread safety)
- Tight coupling controllers to EF (use services layer)

## Integration

- `nc-api-contracts` — NSwag/Swashbuckle for OpenAPI
- `nc-observability` — OpenTelemetry .NET SDK + Application Insights
- `nc-auth-patterns` — Identity, JWT, OAuth via `Microsoft.AspNetCore.Authentication`

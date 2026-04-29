# .NET Integration Test Reference

> Comprehensive guide for writing integration tests that exercise real cross-boundary interactions using WebApplicationFactory, TestContainers, and real databases.

## Project Convention

Integration test projects use the suffix `.Tests.Integration`:

```
MyOrg.WorkTracker.Infrastructure.Tests.Integration/
MyOrg.WorkTracker.Service.Http.Tests.Integration/
MyOrg.WorkTracker.Service.Grpc.Tests.Integration/
```

## MSTest Configuration

```csharp
[assembly: Parallelize(Scope = ExecutionScope.MethodLevel)]
```

Integration tests run in parallel but may use fewer workers than unit tests depending on resource constraints.

## TestContainers

**All integration tests requiring a database MUST use TestContainers.** Never assume a locally running database or use `localhost` defaults.

### Setup

Add the `Testcontainers` NuGet package (and provider-specific package) to the integration test project:

```xml
<PackageReference Include="Testcontainers.MsSql" Version="..." />
<!-- or -->
<PackageReference Include="Testcontainers.PostgreSql" Version="..." />
<PackageReference Include="Testcontainers.CosmosDb" Version="..." />
<PackageReference Include="Testcontainers.MongoDb" Version="..." />
```

### Database Container Lifecycle

Use `[AssemblyInitialize]` / `[AssemblyCleanup]` to share one container across all tests in the project:

```csharp
[TestClass]
public static class TestContainerSetup
{
    private static MsSqlContainer _container = null!;
    public static string ConnectionString { get; private set; } = null!;

    [AssemblyInitialize]
    public static async Task Initialize(TestContext context)
    {
        _container = new MsSqlBuilder()
            .WithImage("mcr.microsoft.com/mssql/server:2022-latest")
            .Build();

        await _container.StartAsync();
        ConnectionString = _container.GetConnectionString();
    }

    [AssemblyCleanup]
    public static async Task Cleanup()
    {
        await _container.DisposeAsync();
    }
}
```

### Using the Container in Tests

```csharp
[TestClass]
public class WorkItemRepositoryIntegrationTestFixture
{
    private WorkTrackerDbContext _dbContext = null!;
    private WorkItemRepository _repository = null!;

    [TestInitialize]
    public void Setup()
    {
        var options = new DbContextOptionsBuilder<WorkTrackerDbContext>()
            .UseSqlServer(TestContainerSetup.ConnectionString)
            .Options;

        _dbContext = new WorkTrackerDbContext(options);
        _dbContext.Database.EnsureCreated();
        _repository = new WorkItemRepository(_dbContext);
    }

    [TestCleanup]
    public void Cleanup()
    {
        _dbContext.Dispose();
    }
}
```

## WebApplicationFactory

For service-level integration tests, override the application's DI container to swap the database connection:

```csharp
[TestClass]
public class ProjectsControllerIntegrationTestFixture
{
    private WebApplicationFactory<Program> _factory = null!;
    private HttpClient _client = null!;

    [TestInitialize]
    public void Setup()
    {
        _factory = new WebApplicationFactory<Program>()
            .WithWebHostBuilder(builder =>
            {
                builder.ConfigureServices(services =>
                {
                    // Remove existing DbContext registration
                    var descriptor = services.SingleOrDefault(
                        d => d.ServiceType == typeof(DbContextOptions<WorkTrackerDbContext>));
                    if (descriptor != null) services.Remove(descriptor);

                    // Add DbContext with TestContainers connection string
                    services.AddDbContext<WorkTrackerDbContext>(options =>
                        options.UseSqlServer(TestContainerSetup.ConnectionString));
                });
            });

        _client = _factory.CreateClient();
    }
}
```

## Test Data Management

- Each test creates and cleans up its own data — never rely on shared seed data
- Use `[TestInitialize]` to set up per-test data via the repository or DbContext directly
- Use transactions that roll back if test isolation requires it:

```csharp
[TestInitialize]
public async Task Setup()
{
    // ... setup DbContext with TestContainers connection
    _transaction = await _dbContext.Database.BeginTransactionAsync();
}

[TestCleanup]
public async Task Cleanup()
{
    await _transaction.RollbackAsync();
    _dbContext.Dispose();
}
```

## Test Naming

Same convention as unit tests — underscores between ALL words:

```
Given_Valid_Request_When_Create_Project_Called_Then_Returns_Created_Status
Given_Non_Existent_Id_When_Get_Project_Called_Then_Returns_Not_Found
```

## What to Test

- Repository methods with real database (CRUD operations)
- EF Core query translation (specifications, paging, filtering)
- Soft-delete global query filters
- Database-generated fields (Id, timestamps)
- WebApplicationFactory end-to-end pipeline (HTTP → Controller → Handler → Repository → DB)
- Service registration and DI wiring

## What NOT to Test

- External services not under your control (mock at the boundary)
- Database engine behavior (joins, ACID — trust the engine)
- Middleware ordering (test through observable behavior)

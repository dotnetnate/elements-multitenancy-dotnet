# .NET HTTP API Test Reference

> Comprehensive guide for testing ASP.NET Web API endpoints including .http file testing, controller unit tests, and integration tests.

## .http File Testing (Primary Approach)

Use `.http` files as the **primary tool** for manual API exploration, documentation, and lightweight verification. These files are executable in VS Code (REST Client extension) and Visual Studio.

### Structure

Place `.http` files alongside the HTTP service project or in a dedicated `http/` folder:

```
MyOrg.WorkTracker.Service.Http/
    http/
        projects.http
        work-items.http
        health.http
```

### Example .http File

```http
@baseUrl = {{$dotenv SERVICE_URL}}

### Health Check
GET {{baseUrl}}/health
Accept: application/json

### List Projects
GET {{baseUrl}}/api/projects?page=1&pageSize=10
Accept: application/json

### Create Project
POST {{baseUrl}}/api/projects
Content-Type: application/json

{
    "name": "New Project",
    "description": "Created via .http file"
}

### Get Project by ID
@projectId = {{$guid}}
GET {{baseUrl}}/api/projects/{{projectId}}
Accept: application/json

### Update Project
PUT {{baseUrl}}/api/projects/{{projectId}}
Content-Type: application/json
If-Match: "1"

{
    "name": "Updated Project",
    "description": "Updated via .http file"
}

### Delete Project
DELETE {{baseUrl}}/api/projects/{{projectId}}
```

### Environment Configuration

Use `.env` files per environment — never hardcode URLs:

```
# .env.development
SERVICE_URL=https://localhost:5001

# .env.staging
SERVICE_URL=https://worktracker-staging.example.com
```

## Controller Unit Tests

Test controller action methods by mocking `ICqrsPipeline`:

```csharp
[TestClass]
public class ProjectsControllerTestFixture
{
    private Mock<ICqrsPipeline> _pipelineMock = null!;
    private ProjectsController _controller = null!;

    [TestInitialize]
    public void Setup()
    {
        _pipelineMock = new Mock<ICqrsPipeline>();
        _controller = new ProjectsController(_pipelineMock.Object);
    }

    [TestMethod]
    public async Task Given_Valid_Request_When_Create_Project_Called_Then_Returns_Created_At_Action()
    {
        // Arrange
        var model = new ProjectModel { Id = Guid.NewGuid(), Name = "Test" };
        _pipelineMock
            .Setup(p => p.Execute<CreateProjectCommand, Result<ProjectModel>>(
                It.IsAny<CreateProjectCommand>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<ProjectModel>.Success(model));

        // Act
        var result = await _controller.CreateProject(
            new CreateProjectRequest { Name = "Test" }, CancellationToken.None);

        // Assert
        result.Should().BeOfType<CreatedAtActionResult>();
        var created = (CreatedAtActionResult)result;
        created.Value.Should().BeEquivalentTo(model);
    }

    [TestMethod]
    public async Task Given_Not_Found_Error_When_Get_Project_Called_Then_Returns_Not_Found()
    {
        // Arrange
        _pipelineMock
            .Setup(p => p.Execute<GetProjectQuery, Result<ProjectModel>>(
                It.IsAny<GetProjectQuery>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<ProjectModel>.Failure(new ProjectNotFoundError()));

        // Act
        var result = await _controller.GetProject(Guid.NewGuid(), CancellationToken.None);

        // Assert
        result.Should().BeOfType<NotFoundObjectResult>();
    }
}
```

## Error Mapping

HTTP API tests must verify correct HTTP status code mapping:

| Error Type | HTTP Status |
|-----------|-------------|
| `VALIDATION_ERROR` | `400 Bad Request` |
| `RESOURCE_NOT_FOUND` | `404 Not Found` |
| `INVALID_OPERATION` | `422 Unprocessable Entity` |
| `INSUFFICIENT_PRIVILEGES` | `403 Forbidden` |
| `VERSION_CONFLICT` | `409 Conflict` |
| Unhandled exception | `500 Internal Server Error` |

## Integration Tests

Use `WebApplicationFactory` with TestContainers for full-pipeline integration tests:

```csharp
[TestClass]
public class ProjectsApiIntegrationTestFixture
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
                    // Swap DB to TestContainers instance
                    var descriptor = services.SingleOrDefault(
                        d => d.ServiceType == typeof(DbContextOptions<WorkTrackerDbContext>));
                    if (descriptor != null) services.Remove(descriptor);

                    services.AddDbContext<WorkTrackerDbContext>(options =>
                        options.UseSqlServer(TestContainerSetup.ConnectionString));
                });
            });

        _client = _factory.CreateClient();
    }

    [TestMethod]
    public async Task Given_Valid_Request_When_Post_Projects_Called_Then_Returns_201_Created()
    {
        var request = new { Name = "Integration Test Project", Description = "Test" };
        var response = await _client.PostAsJsonAsync("/api/projects", request);

        response.StatusCode.Should().Be(HttpStatusCode.Created);
        response.Headers.Location.Should().NotBeNull();
    }
}
```

## Test Naming

Underscores between ALL words:

```
Given_Valid_Request_When_Create_Project_Called_Then_Returns_Created_At_Action
Given_Not_Found_Error_When_Get_Project_Called_Then_Returns_Not_Found
Given_Validation_Error_When_Create_Project_Called_Then_Returns_Bad_Request
```

## Conventions

- Controller test fixture: `{Controller}TestFixture` (e.g., `ProjectsControllerTestFixture`)
- Integration test fixture: `{Feature}ApiIntegrationTestFixture`
- Always test content negotiation (`Accept: application/json`)
- Verify `Location` header on `201 Created` responses
- Test pagination parameters (`page`, `pageSize`)
- Verify `If-Match` / `ETag` headers for optimistic concurrency

## What to Test

- All controller action methods (success + each error type)
- HTTP status code mapping for each `Error` subclass
- Request validation (model binding, FluentValidation)
- Response body structure (property names, types)
- Pagination response metadata
- Content-Type headers

## What NOT to Test

- Business logic (tested in handler unit tests)
- Middleware behavior (authentication, CORS — test through observable behavior)
- Serialization framework (System.Text.Json behavior)

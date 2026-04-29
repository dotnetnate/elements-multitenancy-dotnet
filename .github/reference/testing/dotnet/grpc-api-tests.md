# .NET gRPC API Test Reference

> Comprehensive guide for testing gRPC services using mock `ServerCallContext`, `GrpcChannel`, and `WebApplicationFactory`.

## Unit Tests

Test gRPC service classes by mocking `ICqrsPipeline` and `ServerCallContext`:

```csharp
[TestClass]
public class ProjectsGrpcServiceTestFixture
{
    private Mock<ICqrsPipeline> _pipelineMock = null!;
    private Mock<ServerCallContext> _callContextMock = null!;
    private ProjectsService _service = null!;

    [TestInitialize]
    public void Setup()
    {
        _pipelineMock = new Mock<ICqrsPipeline>();
        _callContextMock = new Mock<ServerCallContext>();
        _service = new ProjectsService(_pipelineMock.Object, CreateMapper());
    }

    [TestMethod]
    public async Task Given_Valid_Request_When_Get_Project_Called_Then_Returns_Protobuf_Response()
    {
        // Arrange
        var model = new ProjectModel { Id = Guid.NewGuid(), Name = "Test" };
        _pipelineMock
            .Setup(p => p.Execute<GetProjectQuery, Result<ProjectModel>>(
                It.IsAny<GetProjectQuery>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<ProjectModel>.Success(model));

        var request = new GetProjectRequest { Id = model.Id.ToString() };

        // Act
        var response = await _service.GetProject(request, _callContextMock.Object);

        // Assert
        response.Should().NotBeNull();
        response.Name.Should().Be("Test");
    }

    [TestMethod]
    public async Task Given_Not_Found_Error_When_Get_Project_Called_Then_Throws_Rpc_Exception_Not_Found()
    {
        // Arrange — pipeline returns not found
        _pipelineMock
            .Setup(p => p.Execute<GetProjectQuery, Result<ProjectModel>>(
                It.IsAny<GetProjectQuery>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<ProjectModel>.Failure(new ProjectNotFoundError()));

        var request = new GetProjectRequest { Id = Guid.NewGuid().ToString() };

        // Act & Assert
        var act = async () => await _service.GetProject(request, _callContextMock.Object);
        await act.Should().ThrowAsync<RpcException>()
            .Where(e => e.StatusCode == StatusCode.NotFound);
    }
}
```

## Error Mapping

| Error Type | gRPC StatusCode |
|-----------|-----------------|
| `VALIDATION_ERROR` | `StatusCode.InvalidArgument` |
| `RESOURCE_NOT_FOUND` | `StatusCode.NotFound` |
| `INVALID_OPERATION` | `StatusCode.FailedPrecondition` |
| `INSUFFICIENT_PRIVILEGES` | `StatusCode.PermissionDenied` |
| `VERSION_CONFLICT` | `StatusCode.Aborted` |
| Unhandled exception | `StatusCode.Internal` |

## Integration Tests

Use `WebApplicationFactory` with `GrpcChannel` and TestContainers:

```csharp
[TestClass]
public class ProjectsGrpcIntegrationTestFixture
{
    private WebApplicationFactory<Program> _factory = null!;
    private GrpcChannel _channel = null!;
    private Projects.ProjectsClient _client = null!;

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

        var httpClient = _factory.CreateDefaultClient();
        _channel = GrpcChannel.ForAddress(httpClient.BaseAddress!, new GrpcChannelOptions
        {
            HttpClient = httpClient
        });
        _client = new Projects.ProjectsClient(_channel);
    }

    [TestMethod]
    public async Task Given_Valid_Request_When_Create_Project_Called_Then_Returns_Project_Response()
    {
        var request = new CreateProjectRequest { Name = "Integration Test" };
        var response = await _client.CreateProjectAsync(request);

        response.Should().NotBeNull();
        response.Name.Should().Be("Integration Test");
    }
}
```

## Health Check Testing

```csharp
[TestMethod]
public async Task Given_Running_Service_When_Health_Check_Called_Then_Returns_Serving()
{
    var healthClient = new Health.HealthClient(_channel);
    var response = await healthClient.CheckAsync(new HealthCheckRequest());

    response.Status.Should().Be(HealthCheckResponse.Types.ServingStatus.Serving);
}
```

## Test Naming

Underscores between ALL words:

```
Given_Valid_Request_When_Get_Project_Called_Then_Returns_Protobuf_Response
Given_Not_Found_Error_When_Get_Project_Called_Then_Throws_Rpc_Exception_Not_Found
Given_Running_Service_When_Health_Check_Called_Then_Returns_Serving
```

## Proto Conditional Fields

When using template conditionals in `.proto` files, ensure test protos match the active feature set:

```protobuf
// Conditional fields for optional features
int32 version = 10;  // Only when EnableOptimisticConcurrency is true
```

## Conventions

- Service unit test fixture: `{Service}GrpcServiceTestFixture`
- Integration test fixture: `{Feature}GrpcIntegrationTestFixture`
- Test both success responses and `RpcException` throwing
- Use `StatusCode` enum values from `Grpc.Core`
- Always test health check endpoint (`Grpc.Health.V1`)

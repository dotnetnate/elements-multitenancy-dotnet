# .NET GraphQL API Test Reference

> Comprehensive guide for testing HotChocolate GraphQL endpoints including mutation/query unit tests and HTTP integration tests.

## Unit Tests

Test mutation and query resolver classes by mocking `ICqrsPipeline`:

```csharp
[TestClass]
public class ProjectMutationsTestFixture
{
    private Mock<ICqrsPipeline> _pipelineMock = null!;
    private ValidationInterceptor? _validationInterceptor;

    [TestInitialize]
    public void Setup()
    {
        _pipelineMock = new Mock<ICqrsPipeline>();
    }

    [TestMethod]
    public async Task Given_Valid_Input_When_Create_Project_Called_Then_Returns_Project()
    {
        // Arrange
        var model = new ProjectModel { Id = Guid.NewGuid(), Name = "Test Project" };
        _pipelineMock
            .Setup(p => p.Execute<CreateProjectCommand, Result<ProjectModel>>(
                It.IsAny<CreateProjectCommand>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<ProjectModel>.Success(model));

        var input = new CreateProjectInput("Test Project", null);

        // Act — test static mutation methods directly
        var result = await ProjectMutations.CreateProject(
            input, _pipelineMock.Object, _validationInterceptor, CancellationToken.None);

        // Assert
        result.Should().NotBeNull();
        result.Name.Should().Be("Test Project");
    }

    [TestMethod]
    public async Task Given_Pipeline_Failure_When_Create_Project_Called_Then_Throws_Graph_Ql_Exception()
    {
        // Arrange
        _pipelineMock
            .Setup(p => p.Execute<CreateProjectCommand, Result<ProjectModel>>(
                It.IsAny<CreateProjectCommand>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<ProjectModel>.Failure(new ValidationError("Invalid")));

        var input = new CreateProjectInput("", null);

        // Act & Assert
        var act = async () => await ProjectMutations.CreateProject(
            input, _pipelineMock.Object, _validationInterceptor, CancellationToken.None);
        await act.Should().ThrowAsync<GraphQLException>();
    }
}
```

## Error Mapping

All `Result` failures map to `GraphQLException`:

| Error Type | GraphQL Behavior |
|-----------|-----------------|
| `VALIDATION_ERROR` | `GraphQLException` with validation details |
| `RESOURCE_NOT_FOUND` | `GraphQLException` with not-found message |
| `INVALID_OPERATION` | `GraphQLException` with operation message |
| Unhandled exception | `GraphQLException` with generic error |

## Integration Tests

Use `WebApplicationFactory` with HTTP POST to `/graphql` and TestContainers for database:

```csharp
[TestClass]
public class ProjectGraphQlIntegrationTestFixture
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
    public async Task Given_Valid_Mutation_When_Create_Project_Called_Then_Returns_Data()
    {
        var query = new
        {
            query = @"
                mutation {
                    createProject(input: { name: ""Test"", description: ""Desc"" }) {
                        id
                        name
                    }
                }"
        };

        var response = await _client.PostAsJsonAsync("/graphql", query);

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var content = await response.Content.ReadAsStringAsync();
        content.Should().Contain("\"name\":\"Test\"");
    }

    [TestMethod]
    public async Task Given_Valid_Query_When_Get_Projects_Called_Then_Returns_Data()
    {
        var query = new
        {
            query = @"
                query {
                    projects {
                        nodes {
                            id
                            name
                        }
                    }
                }"
        };

        var response = await _client.PostAsJsonAsync("/graphql", query);

        response.StatusCode.Should().Be(HttpStatusCode.OK);
    }
}
```

## Test Naming

Underscores between ALL words:

```
Given_Valid_Input_When_Create_Project_Called_Then_Returns_Project
Given_Pipeline_Failure_When_Create_Project_Called_Then_Throws_Graph_Ql_Exception
Given_Valid_Mutation_When_Create_Project_Called_Then_Returns_Data
```

## Conventions

- Mutation test fixture: `{Mutations}TestFixture` (e.g., `ProjectMutationsTestFixture`)
- Query test fixture: `{Queries}TestFixture`
- Integration test fixture: `{Feature}GraphQlIntegrationTestFixture`
- Test static mutation/query methods directly for unit tests
- Use HTTP POST to `/graphql` for integration tests
- Verify both `data` and `errors` fields in GraphQL responses

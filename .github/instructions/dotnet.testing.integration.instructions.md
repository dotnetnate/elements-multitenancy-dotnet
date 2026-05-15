---
applyTo: "**/*Tests.Integration/**/*.cs, **/*Tests.Integration/**/*.csproj"
---

# .NET Integration Test Instructions

Authoritative rules for integration test projects (suffix `.Tests.Integration`). Unit-test rules (`.Tests.Unit`) and performance-test rules (`.Tests.Performance`) are out of scope here.

Integration tests exercise the real collaborators a unit cannot: databases, HTTP/gRPC servers, message brokers, file systems, external SDKs. Use them only when a unit test cannot prove the behaviour; prefer a unit test whenever it can.

## Stack (mandatory)

| Concern | Tool | Notes |
|---|---|---|
| Test framework | **MSTest v4** (`MSTest.Sdk`) | Same `[TestClass]` / `[TestMethod]` / `[TestInitialize]` / `[TestCleanup]` / `[ClassInitialize]` / `[ClassCleanup]` model as unit tests. |
| Assertions | **MSTest `Assert.*` only** | Use `Assert.ThrowsExactly<T>` / `Assert.ThrowsExactlyAsync<T>`. No FluentAssertions, Shouldly, or `.Should()`. |
| Mocking | **None by default** | The point of an integration test is to use the real collaborator. Fake only the dependency that is itself outside the integration boundary (e.g. fake an external SaaS while testing your DB code). FakeItEasy is the chosen library if a fake is unavoidable. |
| External dependencies | **Testcontainers** (`Testcontainers.MsSql`, `Testcontainers.PostgreSql`, etc.) for databases and brokers; `WebApplicationFactory<TEntryPoint>` for ASP.NET hosts; in-memory SQLite for EF Core happy-path checks where production parity is not required. | Never share state across tests; always reset between runs. |

## Project layout

- Test project name: `{ProjectUnderTest}.Tests.Integration`, placed alongside the project under test.
- Test class namespace equals the namespace of the class under test.
- Test class name: `{ClassUnderTest}IntegrationTestFixture` (e.g. `ConcurrencyInterceptorIntegrationTestFixture`).
- Test project references the project under test plus `MSTest.TestFramework` and `MSTest.TestAdapter` (provided transitively by `MSTest.Sdk`).

## MSTest configuration

Every integration test project includes `MSTestSettings.cs`:

```csharp
[assembly: Parallelize(Scope = ExecutionScope.MethodLevel)]
```

Omit `Workers` so MSTest picks a conservative default — integration tests can saturate I/O quickly. If a fixture must serialise (e.g. a single shared container that mutates shared schema), apply `[DoNotParallelize]` to the class.

## Naming

- Test method: `Given_{MethodOrFlowUnderTest}_Called_When_{Conditions}_Then_{ExpectedResult}`.
- Underscores separate every word; combine multiple conditions with `_And_`.
- Test methods are `public` and return `Task` (async-by-default for I/O).

## Test class structure

### Container/host lifecycle scope

Two lifecycles are permitted; pick the narrower one that still passes:

- **Class-scoped (default)** — `[ClassInitialize]` / `[ClassCleanup]` start and dispose a container/host per fixture class. Strong isolation, slower for many small fixtures. Use this when a fixture mutates schema or shared resources in ways that other fixtures must not see.
- **Assembly-scoped (opt-in for hot containers)** — `[AssemblyInitialize]` / `[AssemblyCleanup]` start one container/host once per test assembly and reset state between tests in `[TestInitialize]` / `[TestCleanup]` (recreate schema, truncate tables, or roll back a per-test transaction). Faster across a large suite; safe only when all fixtures in the assembly share a compatible schema and reset their own data.

Within either scope, order members consistently:

1. `[ClassInitialize]` / `[AssemblyInitialize]` — start expensive shared resources (containers, hosts) once.
2. `[ClassCleanup]` / `[AssemblyCleanup]` — dispose them.
3. `private static` fields holding the shared resource (connection string, host, factory).
4. Per-test instance fields (DB context, HTTP client) and `[TestInitialize]` / `[TestCleanup]` to reset state.
5. `[TestMethod]` tests, each using **Arrange / Act / Assert** comments.

```csharp
[TestClass]
public sealed class WorkItemRepositoryIntegrationTestFixture
{
    private static MsSqlContainer _container = null!;
    private static string _connectionString = null!;

    private WorkItemDbContext _db = null!;
    private WorkItemRepository _repository = null!;

    [ClassInitialize]
    public static async Task ClassSetup(TestContext _)
    {
        _container = new MsSqlBuilder().Build();
        await _container.StartAsync();
        _connectionString = _container.GetConnectionString();
    }

    [ClassCleanup]
    public static async Task ClassTeardown()
    {
        await _container.DisposeAsync();
    }

    [TestInitialize]
    public async Task Setup()
    {
        var options = new DbContextOptionsBuilder<WorkItemDbContext>()
            .UseSqlServer(_connectionString)
            .Options;
        _db = new WorkItemDbContext(options);
        await _db.Database.EnsureDeletedAsync();
        await _db.Database.MigrateAsync();
        _repository = new WorkItemRepository(_db);
    }

    [TestCleanup]
    public async Task Teardown() => await _db.DisposeAsync();

    [TestMethod]
    public async Task Given_AddAsync_Called_When_Entity_Is_Valid_Then_Persists_To_Database()
    {
        // Arrange
        var workItem = WorkItem.Create(Guid.NewGuid(), "Integration Item", null, null, null);

        // Act
        await _repository.AddAsync(workItem, CancellationToken.None);
        await _db.SaveChangesAsync();

        // Assert
        var stored = await _db.WorkItems.FindAsync(workItem.Id);
        Assert.IsNotNull(stored);
        Assert.AreEqual("Integration Item", stored.Name);
    }
}
```

For ASP.NET hosts, prefer `WebApplicationFactory<TEntryPoint>` over starting a real Kestrel listener:

```csharp
private static WebApplicationFactory<Program> _factory = null!;
private HttpClient _client = null!;

[ClassInitialize]
public static void ClassSetup(TestContext _) => _factory = new WebApplicationFactory<Program>();

[TestInitialize]
public void Setup() => _client = _factory.CreateClient();
```

## Assertion patterns (MSTest `Assert.*`)

Same rules as unit tests. Common integration-specific shapes:

```csharp
// HTTP responses
Assert.AreEqual(HttpStatusCode.OK, response.StatusCode);
var body = await response.Content.ReadFromJsonAsync<WorkItemDto>();
Assert.IsNotNull(body);

// Persisted entity round-trip
var refetched = await _db.WorkItems.AsNoTracking().FirstAsync(w => w.Id == id);
Assert.AreEqual(expected.Name, refetched.Name);

// gRPC errors
var ex = await Assert.ThrowsExactlyAsync<RpcException>(
    () => _client.GetProjectAsync(new GetProjectRequest { Id = id.ToString() }));
Assert.AreEqual(StatusCode.NotFound, ex.StatusCode);
```

## Test isolation

- **Reset shared state between tests.** Recreate or migrate the schema in `[TestInitialize]`, or use a per-test transaction that is rolled back in `[TestCleanup]`.
- **Never assert on data left by another test.** Every test must arrange the rows it asserts on.
- **No wall-clock waits.** Use cancellation tokens with explicit timeouts, or polling helpers with bounded retries.
- **No sharing of HTTP clients, DbContexts, or channels across tests** beyond the read-only configuration cached in `[ClassInitialize]`.
- **Skip on missing dependencies.** If a required tool (Docker, etc.) is unavailable, fail fast with a clear message rather than silently passing.

## What to integration-test

Test:

- Real EF Core mapping, migrations, concurrency, and provider-specific SQL behaviour.
- HTTP / gRPC contract round-trips through the actual middleware pipeline.
- Authentication, authorization, and pipeline behaviours wired in DI.
- Message broker publish/subscribe round-trips and serialization.
- Anything that depends on driver, transport, or container behaviour you do not control.

Do not integration-test:

- Pure domain logic (use unit tests).
- Validation, mapping, or branching that does not require a real collaborator.
- Performance characteristics (use `.Tests.Performance`).

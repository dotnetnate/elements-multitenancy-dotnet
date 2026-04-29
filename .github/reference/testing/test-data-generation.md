# Test Data Generation Guide

> Strategies for creating test data that is readable, maintainable, and deterministic.

## Principles

1. **Deterministic** — Tests must produce the same result on every run. No random data unless the randomness itself is the subject under test.
2. **Minimal** — Provide only the data needed for the scenario. Don't set properties that are irrelevant to the assertion.
3. **Readable** — A reviewer should understand the scenario from the test data alone, without cross-referencing documentation.
4. **Isolated** — Each test creates its own data. Never share mutable state between tests.

## Strategies

### 1. Inline Constants (Preferred for Unit Tests)

Declare test data as `private readonly` fields at the top of the test fixture:

```csharp
[TestClass]
public class CreateWorkItemCommandHandlerTestFixture
{
    private readonly Guid _projectId = Guid.NewGuid();
    private readonly string _name = "Test Work Item";
    private readonly string _description = "A test description";
    private readonly DateTimeOffset _dueDate = DateTimeOffset.UtcNow.AddDays(7);
    private readonly WorkItemPriority _priority = WorkItemPriority.Medium;
}
```

**When to use:** Simple values, single entity, no inter-entity relationships.

### 2. Factory Methods (For Complex Entities)

When tests need entities in specific states, create private factory methods within the test fixture:

```csharp
private static WorkItem CreatePendingWorkItem(string name = "Test Work Item")
{
    return WorkItem.Create(Guid.NewGuid(), name, null, null, null);
}

private static WorkItem CreateInProgressWorkItem(string name = "Test Work Item")
{
    var workItem = CreatePendingWorkItem(name);
    workItem.Start();
    return workItem;
}

private static WorkItem CreateCompletedWorkItem(string name = "Test Work Item")
{
    var workItem = CreateInProgressWorkItem(name);
    workItem.Complete();
    return workItem;
}
```

Optional parameters provide defaults while allowing tests to override specific values:

```csharp
private static Project CreateProject(
    string name = "Test Project",
    string? description = null,
    ProjectStatus status = ProjectStatus.Active)
{
    var project = Project.Create(name, description);
    if (status == ProjectStatus.Archived) project.Archive();
    return project;
}
```

**When to use:** Entities with stateful behavior, multiple tests need the same entity in different states.

### 3. Reflection for Protected Properties

Domain entities protect `Id` with `protected set`. When tests need a specific Id for correlation:

```csharp
private static WorkItem CreateWorkItemWithId(Guid id)
{
    var workItem = WorkItem.Create(Guid.NewGuid(), "Test", null, null, null);
    typeof(WorkItem).BaseType!.GetProperty("Id")!.SetValue(workItem, id);
    return workItem;
}
```

**Use sparingly.** Only when the test requires a known Id for verifying relationships, event correlation, or mock setup matching.

### 4. Builder Pattern (For Complex Object Graphs)

When entities have many optional properties or nested children, consider a test builder:

```csharp
file sealed class WorkItemBuilder
{
    private Guid _projectId = Guid.NewGuid();
    private string _name = "Test Work Item";
    private string? _description;
    private Guid? _parentWorkItemId;

    public WorkItemBuilder WithProject(Guid projectId) { _projectId = projectId; return this; }
    public WorkItemBuilder WithName(string name) { _name = name; return this; }
    public WorkItemBuilder WithDescription(string description) { _description = description; return this; }
    public WorkItemBuilder WithParent(Guid parentId) { _parentWorkItemId = parentId; return this; }

    public WorkItem Build() => WorkItem.Create(_projectId, _name, _description, _parentWorkItemId, null);
}
```

Mark the builder as `file sealed class` to scope it to the test file. Only introduce builders when factory methods become unwieldy (>5 parameters).

**When to use:** More than 4-5 optional properties, or when tests need to vary different combinations.

### 5. Real Dependencies Over Mocks

For certain infrastructure, use real instances instead of mocks:

**AutoMapper:** Create real mapper with real profiles:

```csharp
private static IMapper CreateMapper()
{
    var config = new MapperConfiguration(cfg =>
    {
        cfg.AddProfile<WorkTrackerMappingProfile>();
        cfg.AddProfile<WorkTrackerHttpMappingProfile>();
    });
    return config.CreateMapper();
}
```

**FluentValidation:** Create real validators with real rules:

```csharp
private static IValidator<CreateWorkItemCommand> CreateValidator()
    => new CreateWorkItemCommandValidator();
```

**When to use:** When the real implementation is fast, deterministic, and exercises meaningful behavior.

### 6. File-Scoped Test Utilities

For test doubles of framework interfaces, use the `file` modifier:

```csharp
file sealed class TestMeterFactory : IMeterFactory
{
    public Meter Create(MeterOptions options) => new(options);
    public void Dispose() { }
}

file sealed class StubEventPublisher : IIntegrationEventPublisher
{
    public readonly List<object> Published = [];

    public Task PublishAsync<T>(string topic, T message, CancellationToken ct = default)
    {
        Published.Add(message!);
        return Task.CompletedTask;
    }
}
```

**When to use:** Test-only implementations of interfaces that are too simple to warrant a mock and too specific to share across test files.

## Anti-Patterns to Avoid

### Shared Mutable State

```csharp
// ❌ Static list shared across tests — order-dependent
private static readonly List<WorkItem> _sharedItems = [];

// ✅ Each test creates its own data
[TestMethod]
public void Test()
{
    var items = new List<WorkItem> { CreatePendingWorkItem() };
}
```

### Over-Specified Test Data

```csharp
// ❌ Irrelevant properties obscure the scenario
var workItem = WorkItem.Create(projectId, "Name", "Desc", null, DateTimeOffset.UtcNow.AddDays(7));
workItem.Status.Should().Be(WorkItemStatus.Pending);  // DueDate is irrelevant

// ✅ Only what matters
var workItem = WorkItem.Create(projectId, "Name", null, null, null);
workItem.Status.Should().Be(WorkItemStatus.Pending);
```

### Magic Values Without Context

```csharp
// ❌ What does this GUID mean?
_repoMock.Setup(r => r.GetByIdAsync(
    Guid.Parse("a1b2c3d4-e5f6-7890-abcd-ef1234567890"), It.IsAny<CancellationToken>()))
    .ReturnsAsync(project);

// ✅ Named field explains purpose
private readonly Guid _existingProjectId = Guid.NewGuid();

_repoMock.Setup(r => r.GetByIdAsync(_existingProjectId, It.IsAny<CancellationToken>()))
    .ReturnsAsync(project);
```

### Mocking What You Don't Own

```csharp
// ❌ Mocking EF DbContext internals
var dbContextMock = new Mock<AppDbContext>();
dbContextMock.Setup(c => c.WorkItems).Returns(mockDbSet.Object);

// ✅ Mock the repository interface
var repoMock = new Mock<IWorkItemRepository>();
repoMock.Setup(r => r.GetByIdAsync(...)).ReturnsAsync(workItem);
```

## Integration Test Data

For integration tests with real databases:

1. **Use transactions that roll back** — each test runs in a transaction scope that rolls back after the test
2. **Unique keys per test** — `Guid.NewGuid()` for IDs, unique suffixed strings for names
3. **Seed minimal data** — only what the specific test scenario requires
4. **Clean up if no transaction** — `[TestCleanup]` to remove test data if transaction rollback is not used
5. **Test containers** — prefer ephemeral database containers over shared test databases for full isolation

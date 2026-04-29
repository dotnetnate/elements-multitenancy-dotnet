# General Testing Guide

> Deep-dive reference for all testing in this repository. For test-type-specific rules auto-injected into editors, see `instructions/testing/*.instructions.md`.

## Testing Stack

| Tool | Purpose |
|------|---------|
| **MSTest v3** | Test framework — `[TestClass]`, `[TestMethod]`, `[TestInitialize]` |
| **MSTest Assert.*** | Standard assertions — `Assert.AreEqual()`, `Assert.IsTrue()`, `Assert.ThrowsException<>()` |
| **FakeItEasy** | Mocking — `A.Fake<T>()`, `A.CallTo()`, `MustHaveHappened()` |
| **WebApplicationFactory** | Integration test hosting for HTTP services |
| **TestContainers** | Disposable database containers for integration tests — never use localhost defaults |

## Test Project Naming

| Project Suffix | Purpose | Speed | Dependencies |
|---------------|---------|-------|--------------|
| `.Tests.Unit` | Isolated logic tests | Fast (<1s per test) | No I/O, no database, no network |
| `.Tests.Integration` | Cross-boundary tests | Medium (~seconds) | Real database, real HTTP, real gRPC |
| `.Tests.Validation` | Build verification / smoke tests | Variable | Real deployed service |

## MSTest Configuration

Every test project includes `MSTestSettings.cs`:

```csharp
// Unit tests — maximum parallelism
[assembly: Parallelize(Workers = 0, Scope = ExecutionScope.MethodLevel)]

// Integration tests — parallelism but potentially fewer workers
[assembly: Parallelize(Scope = ExecutionScope.MethodLevel)]
```

`Workers = 0` uses all available processors. Integration tests may omit the `Workers` parameter to use MSTest defaults.

## Test Class Structure

```csharp
[TestClass]
public class WorkItemTestFixture
{
    // 1. Shared immutable test data as private readonly fields
    private readonly Guid _projectId = Guid.NewGuid();
    private readonly string _name = "Test Work Item";

    // 2. Mocks and system-under-test as private fields
    private Mock<IWorkItemRepository> _workItemRepoMock = null!;
    private CreateWorkItemCommandHandler _handler = null!;

    // 3. Optional [TestInitialize] for setup requiring mocks
    [TestInitialize]
    public void Setup()
    {
        _workItemRepoMock = new Mock<IWorkItemRepository>();
        _handler = new CreateWorkItemCommandHandler(_workItemRepoMock.Object, ...);
    }

    // 4. [TestMethod] methods — Given/When/Then naming with underscores between ALL words
    [TestMethod]
    public async Task Given_Valid_Command_When_Project_Exists_Then_Returns_Success()
    {
        // Arrange
        var command = new CreateWorkItemCommand(_projectId, _name);

        // Act
        var result = await _handler.HandleImpl(command, CancellationToken.None);

        // Assert
        result.IsSuccess().Should().BeTrue();
        result.Value.Should().NotBeNull();
        result.Value!.Name.Should().Be(_name);
    }
}
```

## Test Method Naming

Pattern: `Given_{Context}_When_{Action}_Then_{Expected_Result}`. Always include an underscore between ALL words — never use PascalCase within a segment.

```
✅ Given_Create_Called_When_Valid_Parameters_Then_Work_Item_Created_With_Pending_Status
✅ Given_Valid_Command_When_Project_Exists_Then_Returns_Success
✅ Given_Empty_Name_When_Create_Called_Then_Throws_Argument_Exception

❌ Given_Create_Called_When_ValidParameters_Then_WorkItemCreatedWithPendingStatus
❌ Given_ValidCommand_When_ProjectExists_Then_ReturnsSuccess
```

## Assertion Patterns

### MSTest Assert.* Exclusively

Use standard MSTest assertions:

```csharp
// Value assertions
Assert.IsTrue(result.IsSuccess());
Assert.IsNotNull(result.Value);
Assert.AreEqual("Test Work Item", result.Value!.Name);
Assert.AreEqual(WorkItemStatus.Pending, workItem.Status);
Assert.AreNotEqual(Guid.Empty, workItem.Id);

// Time assertions (tolerance for clock jitter)
Assert.IsTrue(Math.Abs((workItem.CreatedAt - DateTimeOffset.UtcNow).TotalSeconds) < 1);

// Collection assertions
Assert.AreEqual(1, workItem.DomainEvents.Count);
var domainEvent = workItem.DomainEvents.Single();
Assert.IsInstanceOfType<WorkItemCreated>(domainEvent);
Assert.AreEqual(workItem.Id, ((WorkItemCreated)domainEvent).WorkItemId);

// Exception assertions (sync)
Assert.ThrowsException<ArgumentException>(() => WorkItem.Create(Guid.Empty, "name"));

// Exception assertions (async)
var ex = await Assert.ThrowsExceptionAsync<RpcException>(
    async () => await service.GetProjectAsync(id, CancellationToken.None));
Assert.AreEqual(StatusCode.NotFound, ex.StatusCode);

// Result type assertions
var result = await controller.CreateProject(request);
Assert.IsInstanceOfType<CreatedAtActionResult>(result);
```

## Mock Patterns

### Setup

```csharp
// Return value
_projectRepoMock
    .Setup(r => r.GetByIdAsync(It.IsAny<Guid>(), It.IsAny<CancellationToken>()))
    .ReturnsAsync(project);

// Task completion (void async)
_workItemRepoMock
    .Setup(r => r.AddAsync(It.IsAny<WorkItem>(), It.IsAny<CancellationToken>()))
    .Returns(Task.CompletedTask);

// Boolean check
_projectRepoMock
    .Setup(r => r.ExistsAsync(projectId, It.IsAny<CancellationToken>()))
    .ReturnsAsync(true);
```

### Verification

```csharp
// Verify specific argument
_workItemRepoMock.Verify(
    r => r.AddAsync(
        It.Is<WorkItem>(w => w.Name == "Test Work Item"),
        It.IsAny<CancellationToken>()),
    Times.Once);

// Verify NOT called (efficiency check)
_projectRepoMock.Verify(
    r => r.GetByIdAsync(It.IsAny<Guid>(), It.IsAny<CancellationToken>()),
    Times.Never);

// Verify call count
_unitOfWorkMock.Verify(
    u => u.SaveChangesAsync(It.IsAny<CancellationToken>()),
    Times.Once);
```

### Mock Only What You Own

- Mock `IWorkItemRepository`, `IUnitOfWork`, `IMapper`, `ICqrsPipeline`
- Do NOT mock `DbContext`, `HttpClient`, `GrpcChannel`, or third-party libraries
- Use real `MapperConfiguration` with real profiles in tests that verify mapping

## Test Data Patterns

### Inline Constants

Use fields for repeated values, inline for one-off:

```csharp
private readonly Guid _projectId = Guid.NewGuid();
private readonly string _name = "Test Work Item";
private readonly string _description = "Test description";
private readonly DateTimeOffset _dueDate = DateTimeOffset.UtcNow.AddDays(7);
```

### Factory Methods

For complex entity creation in tests:

```csharp
private static WorkItem CreateInProgressWorkItem()
{
    var workItem = WorkItem.Create(Guid.NewGuid(), "Test", null, null, null);
    workItem.Start();
    return workItem;
}

private static WorkItem CreateCompletedWorkItem()
{
    var workItem = CreateInProgressWorkItem();
    workItem.Complete();
    return workItem;
}
```

### Reflection for Test Setup

When Id must be set (normally protected):

```csharp
private static WorkItem CreateWorkItemWithId(Guid id)
{
    var workItem = WorkItem.Create(Guid.NewGuid(), "Test", null, null, null);
    typeof(WorkItem).BaseType!.GetProperty("Id")!.SetValue(workItem, id);
    return workItem;
}
```

Use sparingly — only when the test requires a specific Id for correlation assertions.

### File-Scoped Test Utilities

For test-only implementations, use the `file` modifier to keep them scoped:

```csharp
file sealed class TestMeterFactory : IMeterFactory
{
    public Meter Create(MeterOptions options) => new(options);
    public void Dispose() { }
}
```

### Real AutoMapper Configuration

Tests that verify mapping use real profiles — no mocking:

```csharp
var config = new MapperConfiguration(cfg =>
{
    cfg.AddProfile<WorkTrackerMappingProfile>();
    cfg.AddProfile<WorkTrackerHttpMappingProfile>();
});
var mapper = config.CreateMapper();
```

## What to Test

### Always Test

- All public behavior methods on domain entities
- State transitions (happy path + invalid transitions)
- Domain event raising
- Guard clauses (boundary validation)
- Command handler success and failure paths
- Query handler with and without results
- Specification predicates (`IsSatisfiedBy`)
- Specification composition (`And`, `Or`, `Not`)
- Controller/service action result types
- Error mapping to transport (HTTP status, gRPC StatusCode)

### Skip Testing

- Private methods (test through public API)
- Simple property getters/setters
- AutoMapper configuration (validated at startup)
- Framework behavior (EF change tracking, ASP.NET middleware routing)
- Constructor-only initialization (unless complex logic)

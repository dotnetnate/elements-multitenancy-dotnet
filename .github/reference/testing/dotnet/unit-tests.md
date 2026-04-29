# .NET Unit Test Reference

> Comprehensive guide for writing unit tests in .NET projects using MSTest v4, FakeItEasy, and MSTest Assert.*.

## Project Convention

Unit test projects use the suffix `.Tests.Unit` and reside alongside the project they test:

```
MyOrg.WorkTracker.Domain/
MyOrg.WorkTracker.Domain.Tests.Unit/
MyOrg.WorkTracker.Application/
MyOrg.WorkTracker.Application.Tests.Unit/
```

## MSTest Configuration

Every unit test project includes `MSTestSettings.cs`:

```csharp
[assembly: Parallelize(Workers = 0, Scope = ExecutionScope.MethodLevel)]
```

`Workers = 0` uses all available processors. Unit tests are isolated and must support full parallel execution.

## Test Class Structure

```csharp
[TestClass]
public class CreateWorkItemCommandHandlerTestFixture
{
    // 1. Shared immutable inline constants
    private readonly Guid _projectId = Guid.NewGuid();
    private readonly string _name = "Test Work Item";

    // 2. Mocks and system-under-test
    private Mock<IWorkItemRepository> _workItemRepoMock = null!;
    private Mock<IProjectRepository> _projectRepoMock = null!;
    private Mock<IUnitOfWork> _unitOfWorkMock = null!;
    private CreateWorkItemCommandHandler _handler = null!;

    // 3. TestInitialize — reset mocks per test
    [TestInitialize]
    public void Setup()
    {
        _workItemRepoMock = new Mock<IWorkItemRepository>();
        _projectRepoMock = new Mock<IProjectRepository>();
        _unitOfWorkMock = new Mock<IUnitOfWork>();
        _handler = new CreateWorkItemCommandHandler(
            _workItemRepoMock.Object,
            _projectRepoMock.Object,
            _unitOfWorkMock.Object,
            CreateMapper());
    }

    // 4. Tests — Given/When/Then naming with underscores between ALL words
    [TestMethod]
    public async Task Given_Valid_Command_When_Project_Exists_Then_Returns_Success()
    {
        // Arrange
        _projectRepoMock
            .Setup(r => r.ExistsAsync(_projectId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(true);

        var command = new CreateWorkItemCommand(_projectId, _name);

        // Act
        var result = await _handler.HandleImpl(command, CancellationToken.None);

        // Assert
        result.IsSuccess().Should().BeTrue();
        result.Value.Should().NotBeNull();
        result.Value!.Name.Should().Be(_name);
    }

    [TestMethod]
    public async Task Given_Valid_Command_When_Project_Not_Found_Then_Returns_Not_Found_Error()
    {
        // Arrange
        _projectRepoMock
            .Setup(r => r.ExistsAsync(_projectId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(false);

        var command = new CreateWorkItemCommand(_projectId, _name);

        // Act
        var result = await _handler.HandleImpl(command, CancellationToken.None);

        // Assert
        result.IsSuccess().Should().BeFalse();
        result.Error.Should().BeOfType<ProjectNotFoundError>();
    }
}
```

## Test Naming

Pattern: `Given_{Context}_When_{Action}_Then_{Expected_Result}`

**Every word separated by underscores — never use PascalCase within a segment.**

```
✅ Given_Valid_Command_When_Project_Exists_Then_Returns_Success
✅ Given_Empty_Name_When_Create_Called_Then_Throws_Argument_Exception
✅ Given_Pending_Work_Item_When_Start_Called_Then_Status_Is_In_Progress
✅ Given_Completed_Work_Item_When_Start_Called_Then_Throws_Invalid_Operation

❌ Given_ValidCommand_When_ProjectExists_Then_ReturnsSuccess
❌ Given_Create_Called_When_ValidParameters_Then_WorkItemCreatedWithPendingStatus
```

## Configurable Tests

Use `[DataRow]` for parameterized tests when the same assertion applies to multiple inputs:

```csharp
[DataTestMethod]
[DataRow("")]
[DataRow("   ")]
[DataRow(null)]
public void Given_Invalid_Name_When_Create_Called_Then_Throws_Argument_Exception(string? name)
{
    var act = () => WorkItem.Create(Guid.NewGuid(), name!, null, null, null);
    act.Should().Throw<ArgumentException>();
}
```

## Domain Entity Tests

Test behavior methods, state transitions, guard clauses, and domain events:

```csharp
[TestClass]
public class WorkItemTestFixture
{
    [TestMethod]
    public void Given_Valid_Parameters_When_Create_Called_Then_Work_Item_Has_Pending_Status()
    {
        var workItem = WorkItem.Create(Guid.NewGuid(), "Test", null, null, null);

        workItem.Status.Should().Be(WorkItemStatus.Pending);
    }

    [TestMethod]
    public void Given_Pending_Work_Item_When_Start_Called_Then_Status_Changes_To_In_Progress()
    {
        var workItem = WorkItem.Create(Guid.NewGuid(), "Test", null, null, null);

        workItem.Start();

        workItem.Status.Should().Be(WorkItemStatus.InProgress);
    }

    [TestMethod]
    public void Given_Completed_Work_Item_When_Start_Called_Then_Throws_Invalid_Operation_Exception()
    {
        var workItem = WorkItem.Create(Guid.NewGuid(), "Test", null, null, null);
        workItem.Start();
        workItem.Complete();

        var act = () => workItem.Start();

        act.Should().Throw<InvalidOperationException>();
    }

    [TestMethod]
    public void Given_Create_Called_When_Valid_Parameters_Then_Raises_Work_Item_Created_Event()
    {
        var workItem = WorkItem.Create(Guid.NewGuid(), "Test", null, null, null);

        workItem.DomainEvents.Should().ContainSingle()
            .Which.Should().BeOfType<WorkItemCreated>()
            .Which.WorkItemId.Should().Be(workItem.Id);
    }
}
```

## Specification Tests

Test `IsSatisfiedBy` predicate evaluation:

```csharp
[TestMethod]
public void Given_Matching_Name_When_Is_Satisfied_By_Called_Then_Returns_True()
{
    var spec = new WorkItemNameSpecification("Test");
    var workItem = WorkItem.Create(Guid.NewGuid(), "Test Item", null, null, null);

    spec.IsSatisfiedBy(workItem).Should().BeTrue();
}
```

## Command/Query Handler Tests

### Command Handler Pattern

```csharp
// Success path — verify state + side effects
[TestMethod]
public async Task Given_Valid_Command_When_Handle_Called_Then_Persists_And_Returns_Model()
{
    // Arrange — configure mocks to return success conditions
    _projectRepoMock.Setup(...).ReturnsAsync(true);

    // Act
    var result = await _handler.HandleImpl(command, CancellationToken.None);

    // Assert — result
    result.IsSuccess().Should().BeTrue();

    // Assert — side effects
    _workItemRepoMock.Verify(r => r.AddAsync(
        It.Is<WorkItem>(w => w.Name == _name),
        It.IsAny<CancellationToken>()), Times.Once);
    _unitOfWorkMock.Verify(u => u.SaveChangesAsync(
        It.IsAny<CancellationToken>()), Times.Once);
}

// Failure path — verify NO side effects
[TestMethod]
public async Task Given_Invalid_Command_When_Handle_Called_Then_Returns_Error_Without_Persisting()
{
    // Arrange — configure mocks to return failure conditions
    _projectRepoMock.Setup(...).ReturnsAsync(false);

    // Act
    var result = await _handler.HandleImpl(command, CancellationToken.None);

    // Assert — result
    result.IsSuccess().Should().BeFalse();

    // Assert — no side effects
    _workItemRepoMock.Verify(r => r.AddAsync(
        It.IsAny<WorkItem>(),
        It.IsAny<CancellationToken>()), Times.Never);
    _unitOfWorkMock.Verify(u => u.SaveChangesAsync(
        It.IsAny<CancellationToken>()), Times.Never);
}
```

## What to Test

- All public behavior methods on domain entities
- State transitions (happy path + all invalid transitions)
- Domain event raising (correct type, correct properties)
- Guard clauses and boundary validation
- Command handler success and all known failure paths
- Query handler with and without results
- Specification predicates (`IsSatisfiedBy`)
- Specification composition (`.And()`, `.Or()`, `.Not()`)
- Validator rules (valid input, each validation rule failure)

## What NOT to Test

- Private methods (test through public API)
- Simple property getters/setters
- AutoMapper configuration (validated at startup)
- Framework behavior (EF change tracking, ASP.NET middleware routing)
- Constructor-only initialization without complex logic

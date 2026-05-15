---
applyTo: "**/*Tests.Unit/**/*.cs, **/*Tests.Unit/**/*.csproj"
---

# .NET Unit Test Instructions

Authoritative rules for unit test projects (suffix `.Tests.Unit`). Other suffixes (`.Tests.Integration`, `.Tests.Performance`) are out of scope here.

## Stack (mandatory)

| Concern | Tool | Notes |
|---|---|---|
| Test framework | **MSTest v4** (`MSTest.Sdk`) | Created via `dotnet new mstest`. Uses `[TestClass]`, `[TestMethod]`, `[TestInitialize]`, `[DataTestMethod]`, `[DataRow]`. |
| Assertions | **MSTest `Assert.*` only** | No FluentAssertions, no Shouldly, no `.Should()`. Use `Assert.ThrowsExactly<T>` / `Assert.ThrowsExactlyAsync<T>` (not the deprecated `Assert.ThrowsException`). |
| Mocking | **FakeItEasy** | `A.Fake<T>()`, `A.CallTo(...)`, `MustHaveHappened(...)`. Do not introduce Moq or NSubstitute. |

A unit test must run in well under a second and must not touch I/O, databases, networks, the file system, the system clock, or any other shared mutable state.

## Project layout

- Test project name: `{ProjectUnderTest}.Tests.Unit`, placed alongside the project under test.
- Test file path mirrors the source path: `Foo.Domain/WorkItem.cs` → `Foo.Domain.Tests.Unit/WorkItemTestFixture.cs`.
- Test class namespace equals the namespace of the class under test.
- Test project references the project under test plus `MSTest.TestFramework` and `MSTest.TestAdapter` (provided transitively by `MSTest.Sdk`).

## MSTest configuration

Every unit test project includes `MSTestSettings.cs`:

```csharp
[assembly: Parallelize(Workers = 0, Scope = ExecutionScope.MethodLevel)]
```

`Workers = 0` uses all available processors. Unit tests must be isolated enough to run fully in parallel at the method level.

## Naming

- Test class: `{ClassUnderTest}TestFixture` (e.g. `WorkItemValidatorTestFixture`).
- Test method: `Given_{MethodUnderTest}_Called_When_{Conditions}_Then_{ExpectedResult}`.
  - Underscores separate every word. Combine multiple conditions with `_And_`.
  - ✅ `Given_Validate_Called_When_Argument0_Is_Null_Then_Returns_False`
  - ✅ `Given_Validate_Called_When_Argument0_Is_Null_And_Argument1_Is_Valid_Then_Returns_False`
  - ❌ `Given_ValidateCalled_When_Argument0IsNull_Then_ReturnsFalse`
- Test methods are `public` and return `void` or `Task`.

## Test class structure

Order members consistently:

1. Shared immutable test data — `private readonly` fields.
2. Fakes and the system under test — `private` fields, `null!` initialised, assigned in `[TestInitialize]`.
3. `[TestInitialize]` setup method.
4. `[TestMethod]` / `[DataTestMethod]` tests, each using **Arrange / Act / Assert** comments.

```csharp
[TestClass]
public class CreateWorkItemCommandHandlerTestFixture
{
    // 1. Shared immutable test data
    private readonly Guid _projectId = Guid.NewGuid();
    private readonly string _name = "Test Work Item";

    // 2. Fakes and SUT
    private IWorkItemRepository _workItemRepo = null!;
    private IProjectRepository _projectRepo = null!;
    private IUnitOfWork _unitOfWork = null!;
    private CreateWorkItemCommandHandler _handler = null!;

    // 3. Setup
    [TestInitialize]
    public void Setup()
    {
        _workItemRepo = A.Fake<IWorkItemRepository>();
        _projectRepo = A.Fake<IProjectRepository>();
        _unitOfWork = A.Fake<IUnitOfWork>();
        _handler = new CreateWorkItemCommandHandler(_workItemRepo, _projectRepo, _unitOfWork);
    }

    // 4. Tests
    [TestMethod]
    public async Task Given_Handle_Called_When_Project_Exists_Then_Returns_Success()
    {
        // Arrange
        A.CallTo(() => _projectRepo.ExistsAsync(_projectId, A<CancellationToken>._))
            .Returns(true);
        var command = new CreateWorkItemCommand(_projectId, _name);

        // Act
        var result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        Assert.IsTrue(result.IsSuccess());
        Assert.IsNotNull(result.Value);
        Assert.AreEqual(_name, result.Value.Name);
    }

    [TestMethod]
    public async Task Given_Handle_Called_When_Project_Not_Found_Then_Returns_Not_Found_Error()
    {
        // Arrange
        A.CallTo(() => _projectRepo.ExistsAsync(_projectId, A<CancellationToken>._))
            .Returns(false);
        var command = new CreateWorkItemCommand(_projectId, _name);

        // Act
        var result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        Assert.IsFalse(result.IsSuccess());
        Assert.IsInstanceOfType<ProjectNotFoundError>(result.Error);
    }
}
```

## Assertion patterns (MSTest `Assert.*`)

```csharp
// Values
Assert.IsTrue(result.IsSuccess());
Assert.IsNotNull(result.Value);
Assert.AreEqual("Test Work Item", result.Value.Name);
Assert.AreNotEqual(Guid.Empty, workItem.Id);

// Type checks
Assert.IsInstanceOfType<WorkItemCreated>(domainEvent);
Assert.IsInstanceOfType<CreatedAtActionResult>(httpResult);

// Collections
Assert.AreEqual(1, workItem.DomainEvents.Count);
CollectionAssert.AreEqual(expected, actual);

// Time tolerance (clock jitter)
Assert.IsTrue(Math.Abs((workItem.CreatedAt - DateTimeOffset.UtcNow).TotalSeconds) < 1);

// Exceptions — sync
Assert.ThrowsExactly<ArgumentException>(() => WorkItem.Create(Guid.Empty, "name"));

// Exceptions — async
var ex = await Assert.ThrowsExactlyAsync<RpcException>(
    () => service.GetProjectAsync(id, CancellationToken.None));
Assert.AreEqual(StatusCode.NotFound, ex.StatusCode);
```

Do not invent custom assertion helpers; compose multiple `Assert.*` calls instead.

## Exclusions

- Never use the `ExcludeFromCodeCoverage` attribute or any other mechanism for excluding code from code coverage analysis. If it is already present, do not remove it, but you may not add it on your own.

## FakeItEasy patterns

Return-value setup is shown in the main fixture above. For verification:

```csharp
// Specific argument
A.CallTo(() => _workItemRepo.AddAsync(
        A<WorkItem>.That.Matches(w => w.Name == "Test Work Item"),
        A<CancellationToken>._))
    .MustHaveHappenedOnceExactly();

// Must not have been called
A.CallTo(() => _projectRepo.GetByIdAsync(A<Guid>._, A<CancellationToken>._))
    .MustNotHaveHappened();
```

**Mock only what you own.** Fake your own abstractions (`IWorkItemRepository`, `IUnitOfWork`, `IMapper`). Do not fake framework or third-party types you do not control (`DbContext`, `HttpClient`, `GrpcChannel`, `IMemoryCache`); use real instances or thin wrappers you own.

## Test data

- Promote values to `private readonly` fields when reused across tests; otherwise keep inline.
- For composite domain state, build it via `private static` factory methods on the fixture (e.g. `CreateInProgressWorkItem()` that calls `WorkItem.Create(...).Start()`).
- For a stand-in type referenced from a single test file, use the `file` modifier so it cannot leak. If shared across test files, declare it `internal` instead.

```csharp
file sealed class TestMeterFactory : IMeterFactory
{
    public Meter Create(MeterOptions options) => new(options);
    public void Dispose() { }
}
```

## Parameterised tests

Use `[DataTestMethod]` + `[DataRow]` when the same arrange/act/assert applies to multiple inputs:

```csharp
[DataTestMethod]
[DataRow("")]
[DataRow("   ")]
[DataRow(null)]
public void Given_Create_Called_When_Name_Is_Invalid_Then_Throws_Argument_Exception(string? name)
{
    Assert.ThrowsExactly<ArgumentException>(
        () => WorkItem.Create(Guid.NewGuid(), name!, null, null, null));
}
```

## What to test

Test:

- Every public behaviour method on domain entities and services.
- All state transitions, both valid and invalid.
- Guard clauses and boundary validation.
- Each branch of public conditional logic.

Do not test:

- Private methods directly — exercise them through the public API.
- Trivial property getters/setters with no logic.
- Framework behaviour (EF Core change tracking, ASP.NET routing, DI container resolution, etc.).

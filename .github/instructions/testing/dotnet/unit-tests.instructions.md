---
applyTo: "**/*.Tests.Unit/**/*.cs"
---

## Config

RULE: MSTest v3 — `[TestClass]`, `[TestMethod]`, `[TestInitialize]`
RULE: `[assembly: Parallelize(Workers = 0, Scope = ExecutionScope.MethodLevel)]`

## Naming

PATTERN: `Given_{Context}_When_{Action}_Then_{Expected_Result}` — underscore between ALL words
✅ `Given_Valid_Command_When_Project_Exists_Then_Returns_Success`
❌ `Given_ValidCommand_When_ProjectExists_Then_ReturnsSuccess`
RULE: Test fixture class → `{SystemUnderTest}TestFixture`

## Structure

```csharp
[TestClass]
public class WorkItemTestFixture
{
    private readonly Guid _projectId = Guid.NewGuid();
    private Mock<IWorkItemRepository> _repoMock = null!;

    [TestInitialize]
    public void Setup()
    {
        _repoMock = new Mock<IWorkItemRepository>();
    }

    [TestMethod]
    public void Given_Valid_Data_When_Create_Then_Returns_Pending_Status()
    {
        var workItem = WorkItem.Create(_projectId, "Test", null, null, null);
        workItem.Status.Should().Be(WorkItemStatus.Pending);
    }
}
```

RULE: `[DataTestMethod]` + `[DataRow(...)]` for parameterized tests

## Assertions

RULE: MSTest Assert.* exclusively — use Assert.AreEqual(), Assert.IsTrue(), Assert.ThrowsException<>() etc.
RULE: `Assert.IsTrue(result.IsSuccess())` / `Assert.AreEqual("expected", result.Value!.Name)`
RULE: Exception → `Assert.ThrowsException<T>(() => ...)`
RULE: Async exception → `await Assert.ThrowsExceptionAsync<T>(async () => ...)`
RULE: Collections → `Assert.AreEqual(1, collection.Count)` / `Assert.IsInstanceOfType<T>(item)`

## Mocking

RULE: Mock only what you own — `IWorkItemRepository`, `IUnitOfWork`, `IMapper`, `ICqrsPipeline`
NEVER: Mock `DbContext`, `HttpClient`, `GrpcChannel`, or third-party libraries
RULE: Use real `MapperConfiguration` with real profiles for mapping tests
RULE: `It.IsAny<T>()` for irrelevant params, `It.Is<T>(predicate)` for specific assertions
RULE: Verify side effects with `.Verify(..., Times.Once)` or `Times.Never`

## Domain Entity Tests

RULE: Test creation via `static Create()`, state transitions, guard clauses
RULE: Assert domain events → `.DomainEvents.Should().ContainSingle().Which.Should().BeOfType<WorkItemCreated>()`

## Specification Tests

RULE: Test `IsSatisfiedBy` returns true/false for matching/non-matching entities
RULE: Test `.And()` / `.Or()` / `.Not()` composition

## Handler Tests

RULE: Success path → verify `Result.IsSuccess` + repository calls + mapped output
RULE: Failure path → verify error type + NO side effects (`Times.Never` on SaveChanges)

## What to Test

✅ Domain entity creation, state transitions, guard clauses
✅ Command/query handler success and failure paths
✅ Specification predicates and composition
✅ Domain event raising and handling

## What NOT to Test

❌ Private methods — test via public API
❌ EF change tracking or framework internals
❌ Simple property getters without logic
❌ AutoMapper configuration — validated at startup

## Deep-Dive

→ `.github/reference/testing/general.md`
→ `.github/reference/testing/dotnet/unit-tests.md`
→ `.github/reference/testing/test-data-generation.md`

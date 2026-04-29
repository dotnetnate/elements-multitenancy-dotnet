---
applyTo: "**/*.Tests.Integration/**/*.cs"
---

## Config

RULE: MSTest v3 — `[TestClass]`, `[TestMethod]`, `[TestInitialize]`, `[TestCleanup]`
RULE: `[assembly: Parallelize(Scope = ExecutionScope.MethodLevel)]`
RULE: Service entry point must declare `public static partial class Program;`

## Naming

PATTERN: `Given_{Context}_When_{Action}_Then_{Expected_Result}` — underscore between ALL words
✅ `Given_Valid_Request_When_Create_Project_Then_Returns_201`
❌ `Given_ValidRequest_When_CreateProject_Then_Returns201`
RULE: Test fixture class → `{Feature}IntegrationTestFixture`

## TestContainers (REQUIRED)

RULE: TestContainers REQUIRED for ALL database dependencies — never localhost defaults
RULE: Container lifecycle → `[AssemblyInitialize]`/`[AssemblyCleanup]` for shared container
PATTERN: `WebApplicationFactory<Program>` with DI swap to TestContainers connection string

```csharp
[AssemblyInitialize]
public static async Task AssemblyInit(TestContext _)
{
    Container = new MsSqlBuilder().Build();
    await Container.StartAsync();
}

[AssemblyCleanup]
public static async Task AssemblyClean() => await Container.DisposeAsync();
```

## Data Management

RULE: Each test creates its own data — no shared mutable state
RULE: Use `Guid.NewGuid()` for unique identifiers to avoid collisions
PREFER: Transaction rollback pattern — each test operates within a rolled-back transaction
RULE: Seed only minimal data needed per scenario

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

## What to Test

✅ End-to-end request flow through the CQRS pipeline
✅ Database persistence and retrieval round-trips
✅ Serialization/deserialization of contracts
✅ Error response format (`ProblemDetails` for HTTP, `RpcException` for gRPC)
✅ Authorization pipeline behavior with real identity

## What NOT to Test

❌ Unit-level logic already covered by unit tests
❌ Third-party library internals
❌ Performance characteristics — use performance tests

## Deep-Dive

→ `.github/reference/testing/general.md`
→ `.github/reference/testing/dotnet/integration-tests.md`

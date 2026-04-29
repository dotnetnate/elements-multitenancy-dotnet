---
applyTo: "**/*.Tests.Validation/**/*.cs"
---

## Purpose

RULE: Post-deployment smoke tests against a REAL running service — not in-process test host
RULE: Answer one question: "Is the deployed service operational?"

## Config

RULE: MSTest v3 — `[TestClass]`, `[TestMethod]`
RULE: `[assembly: Parallelize(Scope = ExecutionScope.MethodLevel)]`

## Naming

PATTERN: `Given_{Context}_When_{Action}_Then_{Expected_Result}` — underscore between ALL words
✅ `Given_Service_Running_When_Health_Check_Then_Returns_Healthy`
❌ `Given_ServiceRunning_When_HealthCheck_Then_ReturnsHealthy`
RULE: Test fixture class → `{Service}BvtFixture` or `{Feature}BvtFixture`

## Configuration (NEVER hardcode)

NEVER: Localhost defaults — require explicit config
PATTERN: `ConfigurationBuilder` + `testsettings.json` + environment variable overrides

```csharp
var config = new ConfigurationBuilder()
    .AddJsonFile("testsettings.json", optional: true)
    .AddEnvironmentVariables()
    .Build();
var serviceUrl = config["ServiceUrl"]
    ?? throw new InvalidOperationException("ServiceUrl is required. Set in testsettings.json or SERVICE_URL env var.");
```

## Health Check Tests

RULE: HTTP → `GET /health` returns `200 OK`
RULE: gRPC → `Grpc.Health.V1.Health.HealthClient` → `Check` returns `Serving`

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

✅ Health check endpoints (`/health`, `/ready`)
✅ One create + read round-trip per major entity
✅ Basic error response (e.g., 404 for non-existent resource)

## What NOT to Test

❌ Exhaustive CRUD coverage — integration tests handle this
❌ Edge cases and boundary conditions
❌ Performance or load characteristics

## Deep-Dive

→ `.github/reference/testing/general.md`
→ `.github/reference/testing/dotnet/build-verification-tests.md`

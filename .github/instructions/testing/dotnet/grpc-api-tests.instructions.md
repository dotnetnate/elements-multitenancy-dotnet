---
applyTo: "**/*.Service.Grpc.Tests.*/**/*.cs"
---

## Naming

PATTERN: `Given_{Context}_When_{Action}_Then_{Expected_Result}` — underscore between ALL words
✅ `Given_Valid_Request_When_Get_Project_Then_Returns_Project`
❌ `Given_ValidRequest_When_GetProject_Then_ReturnsProject`
RULE: Service unit test fixture → `{Service}GrpcServiceTestFixture`
RULE: Integration test fixture → `{Feature}GrpcIntegrationTestFixture`

## Unit Tests

RULE: Mock `ICqrsPipeline` + `ServerCallContext`
RULE: Assert correct protobuf response fields on success
RULE: Assert `RpcException` with correct `StatusCode` on failure

### Error Mapping

| Error Type | gRPC StatusCode |
|---|---|
| `VALIDATION_ERROR` | `StatusCode.InvalidArgument` |
| `RESOURCE_NOT_FOUND` | `StatusCode.NotFound` |
| `INVALID_OPERATION` | `StatusCode.FailedPrecondition` |
| `INSUFFICIENT_PRIVILEGES` | `StatusCode.PermissionDenied` |
| `VERSION_CONFLICT` | `StatusCode.Aborted` |
| Unhandled exception | `StatusCode.Internal` |

### Exception Assertion

PATTERN: `await act.Should().ThrowAsync<RpcException>().Where(e => e.StatusCode == StatusCode.NotFound)`

## Integration Tests

RULE: `WebApplicationFactory<Program>` + `GrpcChannel.ForAddress` + TestContainers

```csharp
var httpClient = _factory.CreateDefaultClient();
_channel = GrpcChannel.ForAddress(httpClient.BaseAddress!, new GrpcChannelOptions { HttpClient = httpClient });
_client = new Projects.ProjectsClient(_channel);
```

## Health Check

RULE: Test via `Grpc.Health.V1.Health.HealthClient` → `Check` returns `Serving`

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

## Deep-Dive

→ `.github/reference/testing/general.md`
→ `.github/reference/testing/dotnet/grpc-api-tests.md`

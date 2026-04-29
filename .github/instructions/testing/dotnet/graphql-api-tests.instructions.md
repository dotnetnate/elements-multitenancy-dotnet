---
applyTo: "**/*.Service.GraphQL.Tests.*/**/*.cs"
---

## Naming

PATTERN: `Given_{Context}_When_{Action}_Then_{Expected_Result}` — underscore between ALL words
✅ `Given_Valid_Input_When_Create_Project_Then_Returns_Project`
❌ `Given_ValidInput_When_CreateProject_Then_ReturnsProject`
RULE: Mutation test fixture → `{Mutations}TestFixture`
RULE: Query test fixture → `{Queries}TestFixture`
RULE: Integration test fixture → `{Feature}GraphQLIntegrationTestFixture`

## Unit Tests

RULE: Mock `ICqrsPipeline`, test static mutation/query methods directly
RULE: All `Result` failures → `GraphQLException`
PATTERN: `await act.Should().ThrowAsync<GraphQLException>()`

## Integration Tests

RULE: `WebApplicationFactory<Program>` + HTTP POST to `/graphql` + TestContainers

```csharp
var query = new { query = @"mutation { createProject(input: { name: ""Test"" }) { id name } }" };
var response = await _client.PostAsJsonAsync("/graphql", query);
response.StatusCode.Should().Be(HttpStatusCode.OK);
```

## Error Mapping

| Error Type | Result |
|---|---|
| `VALIDATION_ERROR` | `GraphQLException` with validation details |
| `RESOURCE_NOT_FOUND` | `GraphQLException` with not-found message |
| `INVALID_OPERATION` | `GraphQLException` with operation message |
| Unhandled exception | `GraphQLException` with generic error |

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
→ `.github/reference/testing/dotnet/graphql-api-tests.md`

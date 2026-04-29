---
applyTo: "**/*.Service.Http.Tests.*/**/*.cs"
---

## .http File Testing (PRIMARY)

RULE: `.http` files are the PRIMARY approach for API exploration and documentation
PATTERN: Place `.http` files in HTTP service test project

```http
@baseUrl = {{$dotenv SERVICE_URL}}

### Create a project
POST {{baseUrl}}/api/projects
Content-Type: application/json

{ "name": "Test", "description": "Created from .http" }

### Get all projects
GET {{baseUrl}}/api/projects
```

RULE: Use `###` separators between requests, `@baseUrl = {{$dotenv SERVICE_URL}}` for base URL

## Naming

PATTERN: `Given_{Context}_When_{Action}_Then_{Expected_Result}` — underscore between ALL words
✅ `Given_Valid_Request_When_Post_Project_Then_Returns_201_With_Location`
❌ `Given_ValidRequest_When_PostProject_Then_Returns201WithLocation`
RULE: Controller unit test fixture → `{Controller}TestFixture`
RULE: Integration test fixture → `{Feature}HttpIntegrationTestFixture`

## Controller Unit Tests

RULE: Mock `ICqrsPipeline`, use real `MapperConfiguration` + real validators
RULE: Assert result types: `CreatedAtActionResult`, `OkObjectResult`, `NoContentResult`, `NotFoundResult`

### Error Mapping

| Error Type | HTTP Result |
|---|---|
| `VALIDATION_ERROR` | `BadRequestObjectResult` (400) |
| `RESOURCE_NOT_FOUND` | `NotFoundResult` (404) |
| `INVALID_OPERATION` | `ConflictObjectResult` (409) |
| `INSUFFICIENT_PRIVILEGES` | `ForbidResult` (403) |
| `VERSION_CONFLICT` | `ConflictObjectResult` (409) |

## Integration Tests

RULE: `WebApplicationFactory<Program>` + TestContainers for DB
RULE: Test `ProblemDetails` error response format
RULE: Verify `Location` header on 201, pagination headers, `ETag`/`If-Match` if applicable
RULE: Use `HttpStatusCode` enum values — never integer codes

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
→ `.github/reference/testing/dotnet/http-api-tests.md`

---
applyTo: "**/*contract*/**/*.cs,**/*pact*/**/*.cs,**/*consumer*/**/*.cs,**/*provider*/**/*.cs"
---

## Naming

PATTERN: `Given_{Context}_When_{Action}_Then_{Expected_Result}` — underscore between ALL words
RULE: Test fixture class → `{Service}ContractTestFixture`

## Schema-Based Contracts

| Service Type | Contract Source | Verification |
|---|---|---|
| HTTP | OpenAPI spec | Schema validation |
| gRPC | `.proto` files | Protobuf compilation + backward compat check |
| GraphQL | Schema SDL | Schema diff / breaking change detection |
| Events | Event schema records | Serialization round-trip tests |

## Proto Compatibility Rules

NEVER: Remove or renumber existing fields
NEVER: Change field types
RULE: Add new fields with new field numbers only
RULE: Deprecate with `[deprecated = true]` instead of removing
PREFER: `buf breaking --against '.git#branch=main'` for automated checks

## Integration Event Round-Trip

```csharp
[TestMethod]
public void Given_Event_When_Serialized_Then_Round_Trips()
{
    var original = new WorkItemCreatedEvent { WorkItemId = Guid.NewGuid(), ProjectId = Guid.NewGuid() };
    var json = JsonSerializer.Serialize(original);
    var deserialized = JsonSerializer.Deserialize<WorkItemCreatedEvent>(json);
    deserialized.Should().BeEquivalentTo(original);
}
```

## Pact Workflow

PATTERN: Consumer generates contract → Provider verifies → Share via Pact Broker
RULE: Run provider verification in CI on every API change
RULE: Breaking changes require version bump and consumer notification

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
→ `.github/reference/testing/dotnet/contract-tests.md`

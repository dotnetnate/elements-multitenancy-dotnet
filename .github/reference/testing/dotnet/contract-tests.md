# .NET Contract Test Reference

> Guide for consumer-driven contract testing between services.

## Purpose

Contract tests verify that service APIs conform to agreed-upon contracts between consumers and providers. They catch breaking changes before deployment.

## Schema-Based Contracts

| Service Type | Contract Source | Verification Method |
|-------------|----------------|---------------------|
| HTTP API | OpenAPI spec / request/response records | Schema validation |
| gRPC | `.proto` files | Protobuf compilation + backward compatibility check |
| GraphQL | Schema SDL | Schema diff / breaking change detection |
| Integration Events | Event schema records | Serialization round-trip tests |

## gRPC Proto Compatibility

Proto files serve as contracts. Verify backward compatibility:

```shell
# Use buf or protoc to check breaking changes
buf breaking --against '.git#branch=main'
```

Rules:
- Never remove or renumber existing fields
- Never change field types
- Add new fields with new field numbers
- Deprecate fields with `[deprecated = true]` instead of removing

## Integration Event Contracts

Integration events are contracts between publishers and subscribers. Verify serialization round-trips:

```csharp
[TestMethod]
public void Given_Work_Item_Created_Event_When_Serialized_Then_Round_Trips_Successfully()
{
    var original = new WorkItemCreatedEvent
    {
        WorkItemId = Guid.NewGuid(),
        ProjectId = Guid.NewGuid()
    };

    var json = JsonSerializer.Serialize(original);
    var deserialized = JsonSerializer.Deserialize<WorkItemCreatedEvent>(json);

    deserialized.Should().BeEquivalentTo(original);
}
```

## Consumer-Driven Contracts (Pact)

If using Pact for consumer-driven contracts:

1. **Consumer tests** generate contract files (Pact JSON) describing expected interactions
2. **Provider tests** verify the actual API against consumer contracts
3. Contracts shared via a Pact Broker or committed to a shared location

## Test Naming

Underscores between ALL words:

```
Given_Work_Item_Created_Event_When_Serialized_Then_Round_Trips_Successfully
Given_Proto_Update_When_Checked_Against_Main_Then_No_Breaking_Changes
```

## Conventions

- Contract test fixture: `{Service}ContractTestFixture`
- Store consumer contracts in a shared location accessible to provider tests
- Run provider verification in CI on every change to the API
- Breaking changes require version bump and consumer notification

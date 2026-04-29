---
applyTo: "**/*.cs,**/*.csproj,**/*.sln"
---

# .NET Coding Guidelines

## Naming

| Element | Convention | Example |
|---------|-----------|---------|
| Namespace | PascalCase, match folder path | `MyOrg.WorkTracker.Domain.WorkItem` |
| Class / Record | PascalCase | `WorkItem`, `CreateWorkItemCommand` |
| Interface | `I` + PascalCase | `IWorkItemRepository` |
| Method | PascalCase | `GetById`, `HandleImpl` |
| Property | PascalCase | `ProjectId`, `CreatedAt` |
| Private field | `_camelCase` | `_workItemRepository` |
| Parameter | camelCase | `projectId`, `cancellationToken` |
| Constant | PascalCase | `MeterName` |
| Generic type | `T` + PascalCase | `TId`, `TResult` |
| Test fixture | `{SUT}TestFixture` | `WorkItemTestFixture` |

NEVER: Append `Async` suffix unless both sync and async versions coexist
NEVER: Abbreviate `cancellationToken` — not `ct`, `token`, or `cts`
RULE: Optional param: `CancellationToken cancellationToken = default`

## Types

RULE: All concrete types `sealed` unless designed for inheritance
RULE: `sealed record` with primary constructors for: commands, queries, events, models, DTOs, filters, contracts
RULE: `sealed class` for: entities, handlers, repos, validators, specifications, services
RULE: `class` (not sealed) only for intentional hierarchies (Error types)
RULE: Integration events use `{ get; init; }` properties (serialization compatibility)

Not sealed: `Entity<TId>`, `AggregateRoot<TId>`, `CommandHandler<,>`, `QueryHandler<,>`, AutoMapper `Profile`, ASP.NET controllers

## File Layout

- RULE: One type per file — exception: `file sealed class` test utilities
- RULE: File-scoped namespaces always — never block-scoped
- RULE: Namespace matches folder path exactly

### Member Ordering

1. Private/static fields
2. Private parameterless ctor 
3. Internal hydration ctor
4. Public ctor
5. Public properties (Id first)
6. Collections (`IReadOnlyCollection<T>`)
7. Static factory (`Create(...)`)
8. Non-Private (e.g., public, internal, protected) methods
9. Private methods

### Using Directive Order

System → `MyOrg.Elements.*` → `MyOrg.WorkTracker.Application.*` → `MyOrg.WorkTracker.Domain.*` → Third-party → Infrastructure

## CQRS Pipeline

RULE: Commands → `CommandHandler<TCommand, TResult>` → override `HandleImpl` → return `Result<T>`
RULE: Queries → `QueryHandler<TQuery, TResult>` → override `GetResult` → return `QueryResult<T>`

```csharp
protected override async Task<Result<WorkItemModel>> HandleImpl(
    CreateWorkItemCommand command, CancellationToken cancellationToken)
{
    // 1. Validate preconditions (existence checks)
    // 2. Create/modify domain entity
    // 3. Persist via repository + SaveChangesAsync
    // 4. Publish integration events
    // 5. Record metrics
    // 6. Map and return Result<T>.Success(model)
}
```

RULE: Set `NullResultAdvice = NullResultAdvices.TreatAsNotFound` in query handler ctor for auto-404

## Result Pattern

NEVER: Throw for business failures — return `Result.Failure(error)` with typed error
RULE: `Result<T>.Success(value)` / `Result<T>.Failure(error)`
RULE: Check `result.IsSuccess()` before accessing `result.Value`
RULE: Null-forgiving `!` only after success check: `result.Value!.Name`
RULE: `Result.CreateFailure<T>(errors)` for multiple errors
RULE: Map Result values at layer boundaries (Domain → Application → Service)

## Error Hierarchy

| Error Type | Code | Use |
|-----------|------|-----|
| `ValidationError` | `VALIDATION_ERROR` | Input validation |
| `ResourceNotFoundError` | `RESOURCE_NOT_FOUND` | Entity not found by ID |
| `NotFoundError` | `NOT_FOUND` | Generic not-found |
| `InvalidOperationError` | `INVALID_OPERATION` | Business rule violations |
| `DuplicateObjectError<T>` | `DUPLICATE_OBJECT` | Unique constraint violations |
| `InsufficientPrivilegesError` | `INSUFFICIENT_PRIVILEGES` | Authorization failures |
| `RuntimeExceptionError` | `RUNTIME_EXCEPTION` | Unhandled exceptions |
| `VersionConflictError<K,V>` | `VERSION_CONFLICT` | Concurrency conflicts |

PATTERN: App errors as static factories: `public static Error ProjectNotFound(Guid id) => new ResourceNotFoundError("Project", id.ToString());`

### Error → Transport Mapping

`VALIDATION_ERROR` → 400 / `InvalidArgument` / `GraphQLException`
`RESOURCE_NOT_FOUND` → 404 / `NotFound` / `GraphQLException`
`INVALID_OPERATION` → 422 / `FailedPrecondition` / `GraphQLException`
`INSUFFICIENT_PRIVILEGES` → 403 / `PermissionDenied` / `GraphQLException`
`VERSION_CONFLICT` → 409 / `Aborted` / `GraphQLException`
Unhandled → 500 / `Internal` / `GraphQLException`

## DDD

RULE: Inherit `Entity<TId>` or `AggregateRoot<TId>` — only aggregates get repositories
RULE: Private parameterless ctor (EF), internal hydration ctor (persistence)
RULE: All state via behavior methods — no public setters, `private set` only
RULE: `static Create(...)` factory validates + calls `RaiseDomainEvent()`

### Guard Clauses

PREFER: `ArgumentException.ThrowIfNullOrWhiteSpace(name)` and `ArgumentNullException.ThrowIfNull(repository)`
RULE: `Guid.Empty` → `throw new ArgumentException("...", nameof(id))`
RULE: Invalid enum → `throw new ArgumentOutOfRangeException(nameof(status), status, "...")`
RULE: Domain state → `throw new InvalidOperationException($"Cannot ... with status '{Status}'.")`
PREFER: Pattern matching: `if (Status is not WorkItemStatus.Pending)`, `if (obj is not Entity<TId> other)`

### Specifications

RULE: `sealed class` per spec, override `ToExpression()` → `Expression<Func<T, bool>>`
RULE: Compose: `spec1.And(spec2)`, `spec.Or(other)`, `spec.Not()`

### Domain Events

RULE: Behavior methods call `RaiseDomainEvent(new WorkItemCreated(...))` → events accumulate → `SaveChangesAsync()` dispatches via `IRequestPipeline.Send()`

### Integration Events

RULE: Published explicitly by handler after `SaveChangesAsync()`: `await _eventPublisher.PublishAsync("topic", event, cancellationToken)`

## Validation

RULE: Two layers — both FluentValidation:
1. Service boundary: on HTTP/gRPC contracts → fails fast with transport error
2. Application boundary: on commands via `ValidationBehavior<,>` → `Result.CreateFailure` with `ValidationError[]`

## EF Core

RULE: `AppDbContext` sealed, `IEntityTypeConfiguration<T>` in separate files
RULE: Repositories sealed, one per aggregate root
RULE: `IUnitOfWork.SaveChangesAsync()` dispatches domain events
RULE: Concurrency: `IVersioned<int>` + `ConcurrencyInterceptor` + `.IsConcurrencyToken()` in config
RULE: Soft-delete: `.HasQueryFilter(e => !e.IsDeleted)`

## Mapping

RULE: AutoMapper `Profile` subclasses — one per layer boundary
RULE: `ForCtorParam` for record constructor parameter mapping
RULE: Validate at startup in Development: `mapper.ConfigurationProvider.AssertConfigurationIsValid()`

## Observability

RULE: `BusinessMetrics` class — `Counter<long>` and `Histogram<double>` via `IMeterFactory`
RULE: Tags: `entity.type`, `operation.type`, `status`
RULE: Base handler classes manage `ActivitySource` tracing automatically — no manual tracing in handlers

## Code Style

PREFER: Expression-bodied members for single expressions
PREFER: Pattern matching over type casts: `is null`, `is not null`, `is not WorkItemStatus.Pending`
PREFER: Switch expressions for multi-branch value selection
PREFER: Collection expressions `[]` for empty collections
RULE: Backing field pattern: `private readonly List<T> _items = []; public IReadOnlyCollection<T> Items => _items.AsReadOnly();`
PREFER: String interpolation `$"..."` — never `string.Format()`
RULE: `StringComparison.OrdinalIgnoreCase` for case-insensitive comparisons
RULE: Nullable reference types enabled — use `?` for nullable, `is null` checks, `.HasValue`

## Documentation

RULE: XML `<summary>` on all public types and members
RULE: `<param>` on record primary constructor parameters
PREFER: `<inheritdoc />` for overrides, `<see cref="..."/>` for cross-references

## DI Registration

RULE: Constructor injection exclusively — no service locator
RULE: `Scoped` for repositories and UoW, `Singleton` for metrics/config, `Transient` for pipeline behaviors/validators
RULE: Organize registrations in static extension methods per layer

## Template Conditionals

RULE: Every `#if` / `Condition` must have a corresponding symbol in `.template.config/template.json`
PREFER: Feature-complete blocks over scattered conditionals

## Project Layout

`*.Domain` → entities, aggregates, specs, events, repo interfaces (zero dependencies)
`*.Application` → commands, queries, handlers, validators, mappers, models, errors, metrics
`*.Infrastructure` → EF Core context, repos, UoW, persistence config
`*.Service.Http` / `.Grpc` / `.GraphQL` / `.Console` / `.Mcp` / `.Daemon.*` → service hosts

RULE: Dependency flow: `Service.*` → `Application` → `Domain` ← `Infrastructure`

## Deep-Dive

→ `reference/coding/dotnet/style-guide.md`
→ `reference/coding/dotnet/design-principles.md`

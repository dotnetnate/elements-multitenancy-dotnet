# .NET Style Guide

> Deep-dive reference for C# code style in this repository. For distilled rules auto-injected into editors, see `instructions/coding/dotnet.instructions.md`.

## File Structure

### File-Scoped Namespaces

Always use file-scoped namespaces — never block-scoped:

```csharp
// ✅ Correct
namespace MyOrg.WorkTracker.Domain.WorkItem;

public sealed class WorkItem : AggregateRoot<Guid> { }

// ❌ Wrong
namespace MyOrg.WorkTracker.Domain.WorkItem
{
    public sealed class WorkItem : AggregateRoot<Guid> { }
}
```

### Using Directive Ordering

Implicit usings are enabled (`<ImplicitUsings>enable</ImplicitUsings>`), so `System.*` namespaces are rarely listed. When explicit usings are needed, order:

1. System namespaces (if needed)
2. Framework libraries (`MyOrg.Elements.*`)
3. Application layer (`MyOrg.WorkTracker.Application.*`)
4. Domain layer (`MyOrg.WorkTracker.Domain.*`)
5. Third-party (`AutoMapper`, `FluentValidation`, `FakeItEasy`, `Grpc.Core`, `HotChocolate`)
6. Infrastructure namespaces

### One Type Per File

Each file contains a single public type. Exceptions:
- `file sealed class` utilities in test files (test helpers scoped to the file)
- Closely related types where the secondary type is functionally part of the primary (rare)

## Naming Conventions

### Identifiers

| Element | Convention | Examples |
|---------|-----------|----------|
| Namespace | PascalCase, matches folder path | `MyOrg.WorkTracker.Domain.WorkItem` |
| Class | PascalCase noun | `WorkItem`, `EfProjectRepository` |
| Record | PascalCase noun | `CreateWorkItemCommand`, `WorkItemCreated` |
| Interface | `I` + PascalCase | `IWorkItemRepository`, `IUnitOfWork` |
| Method | PascalCase verb | `Create`, `GetByIdAsync`, `HandleImpl` |
| Property | PascalCase noun | `ProjectId`, `CreatedAt`, `IsDeleted` |
| Private field | `_camelCase` | `_workItemRepository`, `_unitOfWork` |
| Parameter | camelCase | `projectId`, `cancellationToken` |
| Constant | PascalCase | `MeterName`, `DefaultErrorMessage` |
| Generic type parameter | `T` + PascalCase | `TId`, `TResult`, `TCommand`, `TQuery` |

### Async Method Naming

**Go-forward convention:** Do NOT append `Async` suffix unless both sync and async versions coexist. The existing codebase has `Async` suffixes on repository and handler methods — new code should drop the suffix.

```csharp
// ✅ New code
public Task<Project?> GetById(Guid id, CancellationToken cancellationToken = default);

// ⚠️ Existing code (acceptable, will be migrated over time)
public Task<Project?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
```

### CancellationToken Parameter

Always use the full name `cancellationToken` — never abbreviate to `ct`, `token`, or `cts`:

```csharp
// ✅ Correct
public async Task<Result<WorkItem>> Handle(CreateWorkItemCommand command, CancellationToken cancellationToken)

// ❌ Wrong
public async Task<Result<WorkItem>> Handle(CreateWorkItemCommand command, CancellationToken ct)
```

### Test Naming

Class: `{SystemUnderTest}TestFixture` (not `Tests` or `Test`). Method: `Given_{Context}_When_{Action}_Then_{Expected}`:

```csharp
[TestClass]
public class WorkItemTestFixture
{
    [TestMethod]
    public void Given_Create_Called_When_ValidParameters_Then_WorkItemCreatedWithPendingStatus() { }
}
```

## Type Declarations

### Sealed by Default

Every concrete type is `sealed` unless it is explicitly designed for inheritance:

```csharp
public sealed class WorkItem : AggregateRoot<Guid> { }
public sealed record CreateWorkItemCommand(Guid ProjectId, string Name) : ICommand;
public sealed class CreateWorkItemCommandHandler : CommandHandler<CreateWorkItemCommand, Result<WorkItemModel>> { }
public sealed class EfProjectRepository : IProjectRepository { }
public sealed class AppDbContext : DbContext { }
public sealed class CreateWorkItemCommandValidator : AbstractValidator<CreateWorkItemCommand> { }
public sealed class WorkItemNameSpecification : Specification<WorkItem> { }
```

**Exceptions (not sealed):**
- Framework base classes: `Entity<TId>`, `AggregateRoot<TId>`, `CommandHandler<,>`, `QueryHandler<,>`
- AutoMapper `Profile` subclasses
- ASP.NET controllers
- Error hierarchy classes (designed for subclassing)

### Record vs Class Decision

Use **`sealed record`** for immutable data carriers:
- Commands, queries, events, models, DTOs, filters, HTTP/gRPC contracts

Use **`sealed class`** for mutable state or behavior-rich types:
- Domain entities, handlers, repositories, validators, specifications, services, workers

Use **`class`** (not sealed) only for intentional hierarchies:
- Error types (`ValidationError : Error`)

### Record Style

Records use primary constructors. Place `<param>` XML docs on the record itself:

```csharp
/// <summary>Creates a new work item within a project.</summary>
/// <param name="ProjectId">The identifier of the parent project.</param>
/// <param name="Name">The name of the work item.</param>
/// <param name="Description">Optional description.</param>
public sealed record CreateWorkItemCommand(
    Guid ProjectId,
    string Name,
    string? Description = null) : ICommand;
```

For records needing both primary constructor and body (e.g., domain events with computed properties):

```csharp
public sealed record WorkItemCreated(Guid WorkItemId, Guid ProjectId) : IDomainEvent
{
    public DateTimeOffset OccurredOn { get; init; } = DateTimeOffset.UtcNow;
}
```

Integration events use `{ get; init; }` instead of primary constructors (for serialization compatibility):

```csharp
public sealed record WorkItemCreatedEvent
{
    public Guid WorkItemId { get; init; }
    public Guid ProjectId { get; init; }
}
```

## Member Ordering

Within a class, members appear in this order:

1. **Private/static fields** (backing fields, constants)
2. **Private parameterless constructor** (for EF Core materialization)
3. **Internal hydration constructor** (for persistence reconstitution)
4. **Public constructor** (for DI or general use)
5. **Public properties** (Id first, then domain-specific, then computed)
6. **Concurrency members** (Version property, AdvanceVersion method)
7. **Navigation/collection properties** (`IReadOnlyCollection<T>`)
8. **Static factory methods** (`Create(...)`)
9. **Public instance methods** (behavior methods in domain order)
10. **Protected/private methods**

## Access Modifiers

| Modifier | Use For |
|----------|---------|
| `public` | All interfaces, entities, commands, queries, handlers, models, services, controllers |
| `internal` | Hydration constructors on domain entities (infrastructure needs access) |
| `private set` | All domain entity properties (state changed only via behavior methods) |
| `private` | Parameterless constructors on entities (EF-only), backing fields |
| `protected` | Base class members designed for override (`Entity<TId>.Id`, handler virtual methods) |
| `file` | Test utility types scoped to a single test file (`file sealed class TestMeterFactory`) |

## Expression Style

### Expression-Bodied Members

Use for single-expression members:

```csharp
public bool IsDeleted => DeletedAt.HasValue;
public void AdvanceVersion() => Version++;
public override int GetHashCode() => EqualityComparer<TId>.Default.GetHashCode(Id);
public static Error ProjectNotFound(Guid id) => new ResourceNotFoundError("Project", id.ToString());
```

Use block bodies for anything with multiple statements, conditionals, or side effects.

### Pattern Matching

Prefer pattern matching over type casts or equality comparisons:

```csharp
// Null checks
if (workItem is null) { }
if (specification is not null) { }

// Type checks
if (obj is not Entity<TId> other) return false;

// State validation with disjunction
if (Status is not WorkItemStatus.Pending)
    throw new InvalidOperationException($"...");
if (Status is not (WorkItemStatus.Pending or WorkItemStatus.InProgress))
    throw new InvalidOperationException($"...");
```

### Switch Expressions

Use for multi-branch value selection:

```csharp
return sortField?.ToLowerInvariant() switch
{
    "name" => ascending ? query.OrderBy(p => p.Name) : query.OrderByDescending(p => p.Name),
    "status" => ascending ? query.OrderBy(p => p.Status) : query.OrderByDescending(p => p.Status),
    _ => ascending ? query.OrderBy(p => p.CreatedAt) : query.OrderByDescending(p => p.CreatedAt)
};
```

## Collections & Initialization

### Modern Collection Expressions

Use `[]` for empty collections:

```csharp
private readonly List<WorkItem> _children = [];
private readonly List<IDomainEvent> _domainEvents = [];
public ICollection<Error> Errors { get; protected set; } = [];
```

### Backing Field Pattern for Collections

Domain entities expose read-only collections backed by mutable lists:

```csharp
private readonly List<WorkItem> _children = [];
public IReadOnlyCollection<WorkItem> Children => _children.AsReadOnly();
```

## Strings

- Use string interpolation (`$"..."`) for all dynamic strings
- Use `const string` for repeated literals
- Never use `string.Format()`
- Use `StringComparison.OrdinalIgnoreCase` for case-insensitive comparisons

```csharp
$"Cannot start work item with status '{Status}'."
private const string MeterName = "MyOrg.WorkTracker.Business";
```

## Null Handling

- Enable nullable reference types everywhere (`<Nullable>enable</Nullable>`)
- Use `?` for nullable properties: `string? Description`, `DateTimeOffset? DueDate`
- Use `is null` / `is not null` for null checks (not `== null`)
- Use `.HasValue` for nullable value types
- Null-forgiving operator (`!`) only when logically guaranteed after a check
- Default values: `string.Empty` for strings, `default` for CancellationToken

## XML Documentation

### Required On

All public types and members. Every public class, record, interface, method, and property gets a `<summary>`.

### Format

```csharp
/// <summary>Aggregate root representing a unit of work within a project.</summary>
public sealed class WorkItem : AggregateRoot<Guid>
{
    /// <summary>Gets the name of the work item.</summary>
    public string Name { get; private set; }

    /// <summary>Creates a new work item with the specified properties.</summary>
    /// <param name="projectId">The parent project identifier.</param>
    /// <param name="name">The work item name. Must not be null or whitespace.</param>
    /// <returns>A new <see cref="WorkItem"/> in <see cref="WorkItemStatus.Pending"/> status.</returns>
    public static WorkItem Create(Guid projectId, string name) { }
}
```

### Special Cases

- `<inheritdoc />` for overrides where the base class documents the contract
- `<see cref="..."/>` for cross-referencing related types
- `<remarks>` sparingly — only when additional context beyond summary is needed
- `[SuppressMessage]` with `Justification` parameter for intentional rule suppression

## Guard Clauses

Use built-in .NET guard methods where available:

```csharp
ArgumentException.ThrowIfNullOrWhiteSpace(name);
ArgumentNullException.ThrowIfNull(repository);
```

For types without built-in guards:

```csharp
if (id == Guid.Empty)
    throw new ArgumentException("Id must not be empty.", nameof(id));
if (!Enum.IsDefined(status))
    throw new ArgumentOutOfRangeException(nameof(status), status, "Invalid work item status.");
```

Domain state guards use `InvalidOperationException`:

```csharp
if (Status is not WorkItemStatus.Pending)
    throw new InvalidOperationException($"Cannot start work item with status '{Status}'.");
if (IsDeleted)
    throw new InvalidOperationException("Work item is already deleted.");
```

Constructor guards with throw expressions:

```csharp
_context = context ?? throw new ArgumentNullException(nameof(context));
```

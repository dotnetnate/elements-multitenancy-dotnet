# .NET Design Principles

> Deep-dive reference for architectural patterns and design decisions in this repository. For distilled rules, see `instructions/coding/dotnet.instructions.md`.

## CQRS Pipeline

### Overview

The application layer implements Command Query Responsibility Segregation (CQRS) using the Elements framework. Commands mutate state and return `Result<T>`. Queries read state and return `QueryResult<T>`.

### Command Flow

```
Controller/Service → ICqrsPipeline.Execute(command)
    → AuthorizationBehavior → checks IOperationAuthorizationHandler
    → ValidationBehavior → runs FluentValidation validators
    → CommandHandler<TCommand, TResult>.Handle()
        → OnBeforeHandle() (virtual, override for pre-processing)
        → HandleImpl() (abstract, contains business logic)
        → OnAfterHandle() (virtual, override for post-processing)
    → Result<T> returned to caller
```

### Command Handler Structure

```csharp
public sealed class CreateWorkItemCommandHandler
    : CommandHandler<CreateWorkItemCommand, Result<WorkItemModel>>
{
    private readonly IWorkItemRepository _workItemRepository;
    private readonly IProjectRepository _projectRepository;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;
    private readonly IIntegrationEventPublisher _eventPublisher;
    private readonly BusinessMetrics _metrics;

    public CreateWorkItemCommandHandler(
        IWorkItemRepository workItemRepository,
        IProjectRepository projectRepository,
        IUnitOfWork unitOfWork,
        IMapper mapper,
        IIntegrationEventPublisher eventPublisher,
        BusinessMetrics metrics)
    {
        _workItemRepository = workItemRepository;
        _projectRepository = projectRepository;
        _unitOfWork = unitOfWork;
        _mapper = mapper;
        _eventPublisher = eventPublisher;
        _metrics = metrics;
    }

    protected override async Task<Result<WorkItemModel>> HandleImpl(
        CreateWorkItemCommand command,
        CancellationToken cancellationToken)
    {
        // 1. Validate preconditions
        var projectExists = await _projectRepository.ExistsAsync(command.ProjectId, cancellationToken);
        if (!projectExists)
            return Result<WorkItemModel>.Failure(WorkTrackerErrors.ProjectNotFound(command.ProjectId));

        // 2. Create domain entity
        var workItem = WorkItem.Create(command.ProjectId, command.Name, command.Description, ...);

        // 3. Persist
        await _workItemRepository.AddAsync(workItem, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        // 4. Publish integration events
        await _eventPublisher.PublishAsync("workitems", new WorkItemCreatedEvent { ... }, cancellationToken);

        // 5. Record metrics
        _metrics.RecordWorkItemCreated();

        // 6. Map and return
        var model = _mapper.Map<WorkItemModel>(workItem);
        return Result<WorkItemModel>.Success(model);
    }
}
```

### Query Handler Structure

```csharp
public sealed class GetWorkItemByIdQueryHandler
    : QueryHandler<GetWorkItemByIdQuery, QueryResult<WorkItemModel>>
{
    public GetWorkItemByIdQueryHandler(/* dependencies */)
    {
        NullResultAdvice = NullResultAdvices.TreatAsNotFound; // Auto-return 404 on null
    }

    protected override async Task<QueryResult<WorkItemModel>> GetResult(
        GetWorkItemByIdQuery query,
        CancellationToken cancellationToken)
    {
        var workItem = await _workItemRepository.GetByIdAsync(query.WorkItemId, cancellationToken);
        if (workItem is null)
            return QueryResult<WorkItemModel>.NotFoundResult();

        var model = _mapper.Map<WorkItemModel>(workItem);
        return QueryResult<WorkItemModel>.SuccessResult(model);
    }
}
```

### Handler Registration

All handlers are registered via assembly scanning in service configuration:

```csharp
services.AddCqrsHandlersFromAssemblies(assembly);
services.AddNotificationHandlersFromAssemblies(assembly);
services.AddTransient(typeof(IPipelineBehavior<,>), typeof(AuthorizationBehavior<,>));
services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
services.AddElementsPipeline(null, assembly);
```

## Result Pattern

### Core API

`Result` (non-generic base):
- `Errors` — collection of typed `Error` objects
- `IsSuccess()` — `true` when `Errors` is empty
- `IsFailure()` — `true` when `Errors` is non-empty
- `Result.Success()` — factory for success
- `Result.Failure(error)` — factory for single error
- `Result.CreateFailure<TResult>(errors)` — factory for multiple errors

`Result<T>` (generic):
- Inherits all `Result` members
- `Value` — the success payload (nullable)
- `Result<T>.Success(value)` — factory for success with value
- `Result<T>.Failure(error)` — factory for failure

`QueryResult<T>` (query-specific):
- Inherits all `Result<T>` members
- `Pages` — pagination metadata
- `State` — request state enum
- `QueryResult<T>.SuccessResult(value, pages?)` — success with optional pagination
- `QueryResult<T>.NotFoundResult()` — 404-equivalent
- `QueryResult<T>.FailureResult(errors)` — failure

### Usage Rules

1. **Never throw for business failures** — return `Result.Failure()` with a typed error
2. **Check before accessing `Value`** — always call `IsSuccess()` first
3. **Use null-forgiving (`!`) only after success check** — `result.Value!.Name`
4. **Aggregate errors** — `Result.CreateFailure<T>(errorCollection)` for multiple
5. **Map Result values at layer boundaries** — Domain → Application → Service

## Error Hierarchy

### Built-in Error Types

| Class | Code | Constructor | When to Use |
|-------|------|-------------|-------------|
| `Error` | (any) | `{ Code, Message }` | Base — don't use directly |
| `ValidationError` | `VALIDATION_ERROR` | `(propertyName, message, attemptedValue)` | FluentValidation pipeline failures |
| `ResourceNotFoundError` | `RESOURCE_NOT_FOUND` | `(resourceType, resourceId?)` | Entity not found by ID |
| `NotFoundError` | `NOT_FOUND` | `(message)` | Generic not-found (no entity context) |
| `InvalidOperationError` | `INVALID_OPERATION` | `(message)` | Business rule violations after validation |
| `DuplicateObjectError<TConstraint>` | `DUPLICATE_OBJECT` | `(constraint, objectType)` | Unique constraint violations |
| `InsufficientPrivilegesError` | `INSUFFICIENT_PRIVILEGES` | `(message)` | Authorization failures |
| `RuntimeExceptionError` | `RUNTIME_EXCEPTION` | `(exception)` | Unhandled exceptions (auto-wrapped) |
| `VersionConflictError<TKey, TVersion>` | `VERSION_CONFLICT` | `(key, expected, current)` | Optimistic concurrency conflicts |

### Application-Specific Errors

Define app errors as static factory methods in a dedicated class:

```csharp
public static class WorkTrackerErrors
{
    public static Error ProjectNotFound(Guid id) =>
        new ResourceNotFoundError("Project", id.ToString());

    public static Error WorkItemNotFound(Guid id) =>
        new ResourceNotFoundError("WorkItem", id.ToString());
}
```

### Error-to-Transport Mapping

| Error Code | HTTP Status | gRPC StatusCode | GraphQL |
|-----------|-------------|-----------------|---------|
| `VALIDATION_ERROR` | 400 Bad Request | `InvalidArgument` | `GraphQLException` |
| `RESOURCE_NOT_FOUND` | 404 Not Found | `NotFound` | `GraphQLException` |
| `NOT_FOUND` | 404 Not Found | `NotFound` | `GraphQLException` |
| `INVALID_OPERATION` | 422 Unprocessable | `FailedPrecondition` | `GraphQLException` |
| `DUPLICATE_OBJECT` | 409 Conflict | `AlreadyExists` | `GraphQLException` |
| `INSUFFICIENT_PRIVILEGES` | 403 Forbidden | `PermissionDenied` | `GraphQLException` |
| `VERSION_CONFLICT` | 409 Conflict | `Aborted` | `GraphQLException` |
| `RUNTIME_EXCEPTION` | 500 Internal | `Internal` | `GraphQLException` |

## DDD Building Blocks

### Entity

Base class `Entity<TId>` provides:
- `Id` property with `protected set`
- `DomainEvents` collection (read-only)
- `RaiseDomainEvent()` method
- `ClearDomainEvents()` method
- Value equality based on `Id`

### AggregateRoot

`AggregateRoot<TId> : Entity<TId>` — marks the entity as a consistency boundary. Only aggregate roots are persisted directly via repositories.

### Domain Entity Pattern

```csharp
public sealed class WorkItem : AggregateRoot<Guid>
{
    // EF Core needs this
    private WorkItem() { }

    // Infrastructure uses this to reconstitute from persistence
    internal WorkItem(Guid id, Guid projectId, string name, ...) { ... }

    // Public properties — mutable only through behavior methods
    public Guid ProjectId { get; private set; }
    public string Name { get; private set; } = string.Empty;
    public WorkItemStatus Status { get; private set; }
    public DateTimeOffset CreatedAt { get; private set; }
    public DateTimeOffset? CompletedAt { get; private set; }
    public bool IsDeleted => DeletedAt.HasValue;

    // Factory method — validates and raises creation event
    public static WorkItem Create(Guid projectId, string name, ...)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(name);
        if (projectId == Guid.Empty) throw new ArgumentException("...", nameof(projectId));

        var workItem = new WorkItem { Id = Guid.NewGuid(), ProjectId = projectId, Name = name, ... };
        workItem.RaiseDomainEvent(new WorkItemCreated(workItem.Id, projectId));
        return workItem;
    }

    // Behavior methods — validate state transitions, mutate, raise events
    public void Start()
    {
        if (Status is not WorkItemStatus.Pending)
            throw new InvalidOperationException($"Cannot start work item with status '{Status}'.");
        Status = WorkItemStatus.InProgress;
    }
}
```

### Specification Pattern

Each specification encapsulates a single query predicate:

```csharp
public sealed class WorkItemNameSpecification : Specification<WorkItem>
{
    public string SearchName { get; }

    public WorkItemNameSpecification(string name) => SearchName = name;

    public override Expression<Func<WorkItem, bool>> ToExpression() =>
        wi => wi.Name.Contains(SearchName, StringComparison.OrdinalIgnoreCase);
}
```

Compose specifications fluently:

```csharp
Specification<WorkItem>? spec = null;
if (!string.IsNullOrWhiteSpace(filter.Name))
{
    var nameSpec = new WorkItemNameSpecification(filter.Name);
    spec = spec is null ? nameSpec : spec.And(nameSpec);
}
if (filter.Status is not null)
{
    var statusSpec = new WorkItemStatusSpecification(filter.Status.Value);
    spec = spec is null ? statusSpec : spec.And(statusSpec);
}
```

The base `Specification<T>` class provides:
- `ToExpression()` — abstract, returns `Expression<Func<T, bool>>` for EF translation
- `IsSatisfiedBy(T entity)` — compiles and evaluates in-memory (caches compiled delegate)
- `And(other)`, `Or(other)`, `Not()` — composable combinators

## Domain Events

### Flow

1. Behavior method calls `RaiseDomainEvent(new WorkItemCreated(...))`
2. Events accumulate in `Entity.DomainEvents`
3. `AppDbContext.SaveChangesAsync()` collects events from tracked entities via `ChangeTracker`
4. Domain events are cleared from entities
5. Changes are persisted to database
6. Events are dispatched via `IRequestPipeline.Send()` (same process, same transaction scope)

### Domain Event Handlers

Handlers implement `INotificationHandler<TEvent>` from the CQRS pipeline:

```csharp
public sealed class WorkItemCompletedHandler : INotificationHandler<WorkItemCompleted>
{
    public async Task Handle(WorkItemCompleted notification, CancellationToken cancellationToken)
    {
        // React to domain event — cascading logic, side effects
    }
}
```

### Integration Events

Published explicitly by command handlers after `SaveChangesAsync()` — cross-boundary events for external consumers:

```csharp
await _eventPublisher.PublishAsync("workitems", new WorkItemCreatedEvent { ... }, cancellationToken);
```

## Validation Pipeline

### Two-Layer Validation

**Layer 1 — Service boundary** (FluentValidation on contracts):
- Validators for HTTP request models, gRPC messages, GraphQL inputs
- Registered via `AddValidatorsFromAssemblyContaining<>()` + `AddFluentValidationAutoValidation()`
- Fails fast with transport-appropriate error (400, InvalidArgument, etc.)

**Layer 2 — Application boundary** (FluentValidation on commands via pipeline behavior):
- `ValidationBehavior<TRequest, TResponse>` in CQRS pipeline
- Calls `IValidationService.Validate()` with FluentValidation validators
- Converts failures to `ValidationError[]`
- Returns `Result.CreateFailure<TResponse>(errors)` — no exception thrown

### Validator Structure

```csharp
public sealed class CreateWorkItemCommandValidator : AbstractValidator<CreateWorkItemCommand>
{
    public CreateWorkItemCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(200);
        RuleFor(x => x.ProjectId).NotEmpty();
    }
}
```

## Repository & Unit of Work

### Repository Interface (Domain Layer)

```csharp
public interface IWorkItemRepository
{
    Task<WorkItem?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<WorkItem>> GetAllAsync(CancellationToken cancellationToken = default);
    Task AddAsync(WorkItem workItem, CancellationToken cancellationToken = default);
    Task UpdateAsync(WorkItem workItem, CancellationToken cancellationToken = default);
    Task<bool> ExistsAsync(Guid id, CancellationToken cancellationToken = default);
    Task<(IReadOnlyList<WorkItem> Items, int TotalCount)> SearchAsync(
        Specification<WorkItem>? specification,
        PagingSpecification? paging,
        CancellationToken cancellationToken = default);
}
```

### EF Repository Implementation (Infrastructure Layer)

```csharp
public sealed class EfWorkItemRepository : IWorkItemRepository
{
    private readonly AppDbContext _context;

    public EfWorkItemRepository(AppDbContext context)
    {
        _context = context;
    }

    public async Task<WorkItem?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
        => await _context.WorkItems.FindAsync([id], cancellationToken);

    public Task AddAsync(WorkItem workItem, CancellationToken cancellationToken = default)
    {
        _context.WorkItems.Add(workItem);
        return Task.CompletedTask; // Sync add, async save via UoW
    }
}
```

### Unit of Work

```csharp
public interface IUnitOfWork
{
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
    void TrackAggregate<T>(T aggregate) where T : class;
}
```

`EfUnitOfWork` delegates to `AppDbContext.SaveChangesAsync()`, which handles domain event collection and dispatch. `TrackAggregate()` is a no-op for EF (change tracker handles it automatically).

## Mapping

### AutoMapper Profiles

One profile per layer boundary:

**Application → Domain models:**
```csharp
public class WorkTrackerMappingProfile : Profile
{
    public WorkTrackerMappingProfile()
    {
        CreateMap<WorkItem, Models.WorkItem>()
            .ForCtorParam("Status", opt => opt.MapFrom(src => src.Status.ToString()));
    }
}
```

**Service → Application commands:**
```csharp
public class WorkTrackerHttpMappingProfile : Profile
{
    public WorkTrackerHttpMappingProfile()
    {
        // Request → Command (composite mapping from route + body)
        CreateMap<(Guid ProjectId, CreateWorkItemRequest Body), CreateWorkItemCommand>()
            .ForCtorParam("Name", opt => opt.MapFrom(src => src.Body.Name));

        // Application model → Response
        CreateMap<Application.Models.WorkItem, CreateWorkItemResponse>();
    }
}
```

### Validation at Startup

In Development, assert all mappings are valid:

```csharp
if (app.Environment.IsDevelopment())
    app.Services.GetRequiredService<IMapper>().ConfigurationProvider.AssertConfigurationIsValid();
```

## Dependency Injection

### Registration Pattern

Organize registrations in static extension methods per layer:

```csharp
// Program.cs
builder.Services.AddApplicationServices();
builder.Services.AddInfrastructureServices(builder.Configuration);

// ApplicationConfiguration.cs
public static IServiceCollection AddApplicationServices(this IServiceCollection services)
{
    var assembly = typeof(ApplicationConfiguration).Assembly;
    services.AddCqrsHandlersFromAssemblies(assembly);
    services.AddNotificationHandlersFromAssemblies(assembly);
    services.AddAutoMapper(assembly);
    services.AddSingleton<BusinessMetrics>();
    return services;
}
```

### Rules

- Constructor injection exclusively — no service locator
- Interface-based registration at layer boundaries
- `Scoped` for repositories and UoW (per-request)
- `Singleton` for metrics, configuration, immutable services
- `Transient` for pipeline behaviors and validators

## Observability

### Metrics

```csharp
public sealed class BusinessMetrics
{
    public const string MeterName = "MyOrg.WorkTracker.Business";

    private readonly Counter<long> _projectsCreated;
    private readonly Counter<long> _workItemsCreated;
    private readonly Histogram<double> _operationDuration;

    public BusinessMetrics(IMeterFactory meterFactory)
    {
        var meter = meterFactory.Create(MeterName);
        _projectsCreated = meter.CreateCounter<long>("projects.created");
        _workItemsCreated = meter.CreateCounter<long>("workitems.created");
        _operationDuration = meter.CreateHistogram<double>("operations.duration", "ms");
    }

    public void RecordWorkItemCreated() => _workItemsCreated.Add(1,
        new KeyValuePair<string, object?>("entity.type", "workitem"),
        new KeyValuePair<string, object?>("operation.type", "create"));
}
```

### Tracing

Base `CommandHandler`/`QueryHandler` classes create activities automatically:
- Activity name: `[CommandHandler]-{HandlerName}.Handle`
- Error recorded with `otel.status_code=ERROR`, `error.type`, exception details
- No manual tracing needed in handler implementations

### Health Checks

- HTTP: `/health` (liveness) and `/ready` (readiness) with `HealthChecks.UI.Client`
- gRPC: `AddGrpcHealthChecks()` + `MapGrpcHealthChecksService()`

## Template Engine Conditionals

This solution is a `dotnet new` template with optional features controlled by template symbols.

### In .csproj Files

```xml
<ItemGroup Condition="'$(EnableOptimisticConcurrency)' == 'true'">
    <PackageReference Include="MyOrg.Elements.Concurrency" />
</ItemGroup>
```

### In C# Code

```csharp
#if EnableOptimisticConcurrency
public int Version { get; private set; }
public void AdvanceVersion() => Version++;
#endif
```

### Rules

- Every conditional must have a corresponding symbol in `.template.config/template.json`
- Keep conditional regions small and self-contained
- Prefer feature-complete blocks over scattered conditionals
- Test both enabled and disabled paths

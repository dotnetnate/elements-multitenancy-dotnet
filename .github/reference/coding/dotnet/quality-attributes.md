# .NET Quality Attributes

> Deep-dive reference for cross-cutting quality concerns: performance, security, observability, and resilience.

## Performance

### Pagination

All queries returning collections must support pagination. Never return unbounded result sets.

```csharp
public sealed record PagingSpecification
{
    public int PageNumber { get; init; } = 1;
    public int PageSize { get; init; } = 25;
    public string? SortField { get; init; }
    public bool SortAscending { get; init; } = true;
}
```

Repository enforcement:
- `SearchAsync` applies `Skip((page - 1) * size).Take(size)` after filtering
- `GetAllAsync` applies `.Take(1000)` as a safety cap
- `QueryResult<T>` carries `PaginationData` (page, size, total count)

### Efficient Data Access

- Prefer `ExistsAsync()` over `GetByIdAsync()` when only checking existence
- Use `GetIncompleteRequiredChildItemCountAsync()` instead of loading full child collections
- Avoid N+1 queries — use `.Include()` when child data is needed
- Use `CountAsync()` instead of loading collections to count

### Compiled Expressions

Specifications cache compiled delegates for in-memory evaluation:

```csharp
private Func<T, bool>? _compiledExpression;

public bool IsSatisfiedBy(T entity)
{
    _compiledExpression ??= ToExpression().Compile();
    return _compiledExpression(entity);
}
```

The `ToExpression()` remains a lambda expression tree for EF Core translation. `Compile()` is lazy and cached.

### Async Best Practices

- All I/O-bound operations are `async`/`await` — never block with `.Result` or `.Wait()`
- Pass `CancellationToken` through every async call chain
- Use `Task.CompletedTask` for synchronous implementations of async interfaces:

```csharp
public Task AddAsync(WorkItem workItem, CancellationToken cancellationToken = default)
{
    _context.WorkItems.Add(workItem); // Sync add to change tracker
    return Task.CompletedTask;        // Save happens via UoW
}
```

### Global Query Filters

Soft-deleted entities are excluded automatically:

```csharp
// In IEntityTypeConfiguration<T>
builder.HasQueryFilter(e => !e.IsDeleted);
```

Prevents accidentally loading deleted data. Use `.IgnoreQueryFilters()` when explicitly needed.

## Security

### Authorization Pipeline

Authorization runs as a CQRS pipeline behavior before validation and handling:

```csharp
// Pipeline order:
// 1. AuthorizationBehavior → IOperationAuthorizationHandler
// 2. ValidationBehavior → FluentValidation
// 3. Handler → business logic
```

Implementation:
- `IOperationAuthorizationHandler.HandleAsync()` receives the operation context and command/query
- Returns `InsufficientPrivilegesError` on denial
- Default: `PassThroughOperationAuthorizationHandler` allows all (replaced in production)
- `IOperationContext` carries `IdentityReference`, operation name, and properties

### Input Validation

Two layers prevent malicious or malformed input:

1. **Service boundary** — FluentValidation on HTTP/gRPC/GraphQL contracts catches obvious violations (empty required fields, length limits, format constraints) before reaching the pipeline
2. **Application boundary** — `ValidationBehavior` runs FluentValidation on commands, returns `ValidationError[]` as `Result.Failure` without throwing

### Identity Pipeline

```csharp
app.UseAuthentication();
app.UseIdentityContext();  // Extracts identity from ClaimsPrincipal
app.UseAuthorization();
```

`IOperationContext` is scoped per-request and populated before handlers execute.

### Data Protection

- **Parameterized queries** — EF Core LINQ only; no raw SQL string concatenation
- **No secrets in code** — Connection strings, API keys, credentials via `IConfiguration` from environment/secret stores
- **Structured logging sanitization** — Never log credentials, PII, or authentication tokens
- **Concurrency protection** — `VersionConflictError` prevents lost updates in concurrent scenarios

## Observability

### Metrics Architecture

```csharp
public sealed class BusinessMetrics
{
    public const string MeterName = "MyOrg.WorkTracker.Business";

    private readonly Counter<long> _projectsCreated;
    private readonly Counter<long> _workItemsCreated;
    private readonly Counter<long> _workItemsCompleted;
    private readonly Histogram<double> _operationDuration;

    public BusinessMetrics(IMeterFactory meterFactory)
    {
        var meter = meterFactory.Create(MeterName);
        _projectsCreated = meter.CreateCounter<long>("projects.created", description: "Number of projects created");
        _workItemsCreated = meter.CreateCounter<long>("workitems.created", description: "Number of work items created");
        _workItemsCompleted = meter.CreateCounter<long>("workitems.completed", description: "Number of work items completed");
        _operationDuration = meter.CreateHistogram<double>("operations.duration", "ms", "Operation duration");
    }

    public void RecordProjectCreated() => _projectsCreated.Add(1,
        new KeyValuePair<string, object?>("entity.type", "project"),
        new KeyValuePair<string, object?>("operation.type", "create"));
}
```

### Metric Guidelines

- Use `IMeterFactory` for metric creation (enables DI-scoped testing)
- Metric names: lowercase, dot-separated: `workitems.created`, `operations.duration`
- Tags follow OpenTelemetry semantic conventions: `entity.type`, `operation.type`, `status`
- Record metrics in command handlers after successful persistence

### Distributed Tracing

Framework-provided tracing in base handler classes:

```csharp
// Automatically created by CommandHandler/QueryHandler base classes:
// Activity name: [CommandHandler]-CreateWorkItemCommandHandler.Handle
// Activity name: [QueryHandler]-GetWorkItemByIdQueryHandler.GetResult

// On error:
// otel.status_code = ERROR
// error.type = <exception type>
// Exception details recorded
```

No manual `Activity` creation needed in handler implementations. The framework handles span creation, error recording, and context propagation.

### Telemetry Pipeline Configuration

```csharp
builder.Services.AddOpenTelemetry()
    .WithMetrics(metrics =>
    {
        metrics.AddAspNetCoreInstrumentation();
        metrics.AddHttpClientInstrumentation();
        metrics.AddRuntimeInstrumentation();
        metrics.AddMeter(BusinessMetrics.MeterName);
    })
    .WithTracing(tracing =>
    {
        tracing.AddAspNetCoreInstrumentation();
        tracing.AddHttpClientInstrumentation();
    })
    .UseOtlpExporter();
```

### Health Checks

HTTP services expose:
- `/health` — liveness probe (is the process alive?)
- `/ready` — readiness probe (are dependencies healthy?)
- Uses `HealthChecks.UI.Client.UIResponseWriter` for detailed JSON output

gRPC services:
- `AddGrpcHealthChecks()` registers gRPC health service
- `MapGrpcHealthChecksService()` maps the health endpoint

### Structured Logging

```csharp
// ✅ Named placeholders for structured queries
_logger.LogInformation("Processing {OrderId} for {CustomerId}", orderId, customerId);

// ❌ String interpolation destroys structure
_logger.LogInformation($"Processing {orderId} for {customerId}");
```

Log levels by purpose:
| Level | Use For |
|-------|---------|
| `Trace` | Method entry/exit, very verbose flow |
| `Debug` | Developer-useful diagnostics |
| `Information` | Business events: item created, project archived |
| `Warning` | Recoverable issues: retry, fallback used |
| `Error` | Failures requiring attention: unhandled exception |
| `Critical` | Process-threatening: out of memory, dead dependency |

## Resilience

### Optimistic Concurrency

The application uses optimistic concurrency control for aggregate updates:

1. **Domain interface**: `IVersioned<int>` — entities implement `Version` property and `AdvanceVersion()`
2. **EF interceptor**: `ConcurrencyInterceptor` increments `Version` on `SaveChanges`
3. **EF configuration**: `.IsConcurrencyToken()` on `Version` column
4. **Exception flow**: EF throws `DbUpdateConcurrencyException` → `ConcurrencyInterceptor` converts to `ConcurrencyConflictException` → `CommandHandler` base catches and returns `VersionConflictError`
5. **Transport mapping**: HTTP 409, gRPC `Aborted`

```csharp
// Entity:
public int Version { get; private set; }
public void AdvanceVersion() => Version++;

// EF Config:
builder.Property(e => e.Version).IsConcurrencyToken();

// Result on conflict:
VersionConflictError<Guid, int>(entityKey, expectedVersion, currentVersion)
```

### CancellationToken Propagation

Every async method accepts and forwards `CancellationToken`:

```csharp
public async Task<Result<WorkItemModel>> HandleImpl(
    CreateWorkItemCommand command,
    CancellationToken cancellationToken)
{
    var projectExists = await _projectRepository.ExistsAsync(command.ProjectId, cancellationToken);
    // ... every subsequent async call passes cancellationToken
    await _unitOfWork.SaveChangesAsync(cancellationToken);
    await _eventPublisher.PublishAsync("workitems", event, cancellationToken);
}
```

### Error Isolation

- Handler exceptions are caught by base class tracing → recorded as telemetry events
- Global `UseExceptionHandler` catches unhandled exceptions → logs with `ReferenceId` → returns `ProblemDetails` (500)
- Each handler failure returns a typed `Result.Failure` — errors don't propagate as exceptions across handler boundaries
- Domain events handlers failing do not roll back the original operation (fire-and-forget within the same request)

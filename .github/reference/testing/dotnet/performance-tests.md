# .NET Performance Test Reference

> Guide for performance testing, benchmarking, and load testing.

## Micro-Benchmarks

Use **BenchmarkDotNet** for isolated performance measurement of critical paths:

```csharp
[MemoryDiagnoser]
public class SpecificationBenchmarks
{
    private readonly WorkItemNameSpecification _spec = new("test");
    private readonly WorkItem _workItem = WorkItem.Create(Guid.NewGuid(), "test item", null, null, null);

    [Benchmark]
    public bool Is_Satisfied_By() => _spec.IsSatisfiedBy(_workItem);

    [Benchmark]
    public Expression<Func<WorkItem, bool>> To_Expression() => _spec.ToExpression();
}
```

## Load Tests

Use tools like **k6**, **NBomber**, or **Artillery** for HTTP/gRPC endpoint load testing:

- Define realistic user scenarios (create project → add work items → complete items)
- Establish baseline metrics before changes
- Test with expected concurrency levels (10, 50, 100 concurrent users)
- Monitor p50, p95, p99 latency and error rates

## What to Measure

| Metric | Target |
|--------|--------|
| Throughput | Requests per second at target concurrency |
| Latency | p50, p95, p99 response times |
| Memory | Allocation rate, GC pressure (via `MemoryDiagnoser`) |
| Database | Query execution time, connection pool utilization |

## Performance Patterns in This Codebase

- Pagination with `PagingSpecification` (max 1000 records per page)
- `ExistsAsync` instead of `GetByIdAsync` for existence checks
- Compiled specification expressions (cached delegates)
- Global query filters for soft-delete (avoid loading unnecessary data)
- `GetAllAsync` with `.Take(1000)` safety cap

## Conventions

- Benchmark class: `{Feature}Benchmarks`
- Run benchmarks in Release mode only: `dotnet run -c Release`
- Compare before/after with `BenchmarkDotNet.Columns.StatisticalTestColumn`
- Never commit benchmark artifacts — add `/BenchmarkDotNet.Artifacts/` to `.gitignore`

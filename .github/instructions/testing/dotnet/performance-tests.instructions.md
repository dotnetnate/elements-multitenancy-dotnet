---
applyTo: "**/*Tests.Performance*/**/*.cs,**/*Tests.Perf*/**/*.cs,**/*Tests.Benchmark*/**/*.cs"
---

## Naming

PATTERN: `Given_{Context}_When_{Action}_Then_{Expected_Result}` — underscore between ALL words
RULE: Test fixture class → `{SystemUnderTest}TestFixture`

## BenchmarkDotNet

RULE: `[MemoryDiagnoser]` on benchmark class, `[Benchmark]` on methods
RULE: Run in Release mode ONLY — never Debug
NEVER: Commit benchmark artifacts to repo — store baselines in CI artifacts

```csharp
[MemoryDiagnoser]
public class SpecificationBenchmarks
{
    [Benchmark]
    public bool IsSatisfiedBy() => _spec.IsSatisfiedBy(_workItem);
}
```

## Load Testing

PREFER: k6, NBomber, or Artillery for HTTP/gRPC endpoint load testing
RULE: Define realistic user scenarios (create → add items → complete)
RULE: Test at expected concurrency levels (10, 50, 100 concurrent users)

## What to Measure

RULE: Throughput → requests/second at target concurrency
RULE: Latency → p50, p95, p99 response times
RULE: Memory → allocation rate, GC pressure via `MemoryDiagnoser`
RULE: Database → query execution time, connection pool utilization

## Codebase Performance Patterns

RULE: `PagingSpecification` with max 1000 records per page
RULE: `ExistsAsync` instead of `GetByIdAsync` for existence checks
RULE: Compiled specification expressions (cached delegates)
RULE: `GetAllAsync` with `.Take(1000)` safety cap
RULE: Performance regressions >10% from baseline must be investigated

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
→ `.github/reference/testing/dotnet/performance-tests.md`

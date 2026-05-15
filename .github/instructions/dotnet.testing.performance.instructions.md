---
applyTo: "**/*Tests.Performance/**/*.cs, **/*Tests.Performance/**/*.csproj"
---

# .NET Performance Test Instructions

Authoritative rules for performance test projects (suffix `.Tests.Performance`). Unit-test rules (`.Tests.Unit`) and integration-test rules (`.Tests.Integration`) are out of scope here.

Performance tests measure throughput, latency, and allocations of code under controlled conditions. They are not regression tests for behaviour — that is the job of unit and integration tests. A performance test must produce a number, not just a pass/fail.

## Stack (mandatory)

| Concern | Tool | Notes |
|---|---|---|
| Benchmark framework | **BenchmarkDotNet** | `[MemoryDiagnoser]`, `[Benchmark]`, `[GlobalSetup]`, `[Params]`. Run via a `Program.Main` entry point that calls `BenchmarkRunner.Run<T>()`. |
| Project type | **Console application** (`<OutputType>Exe</OutputType>`) built in `Release` only — BenchmarkDotNet refuses Debug builds. |
| MSTest | **Not used.** Performance projects do not use `[TestClass]` / `[TestMethod]`. |
| Mocking | **None.** Benchmarks measure real code paths; faking distorts results. If an external dependency is unavoidable, isolate it behind a deterministic in-memory stand-in defined inside the benchmark project itself. |

## Project layout

- Project name: `{ProjectUnderTest}.Tests.Performance`, placed alongside the project under test.
- **Benchmark file path mirrors the source path** of the class under test, identical to the unit-test convention.
  - `Foo.Domain/Workflows/WorkItem.cs` → `Foo.Domain.Tests.Performance/Workflows/WorkItemBenchmarks.cs`.
  - `Elements.Core/Security/ClaimsPrincipalExtensions.cs` → `Elements.Core.Tests.Performance/Security/ClaimsPrincipalExtensionsBenchmarks.cs`.
- **Benchmark class namespace equals the namespace of the class under test** (NOT the test-project namespace). This matches the unit-test rule and keeps `using` statements minimal.
  - Class under test in `MyOrg.Elements.Security` → benchmark class also in `MyOrg.Elements.Security`.
- One `*Benchmarks.cs` class per class under test, named `{ClassUnderTest}Benchmarks`.
- One `Program.cs` at the project root that delegates to `BenchmarkSwitcher` so any benchmark can be selected from the CLI. `Program.cs` is infrastructure and uses the project's default namespace.
- Project references the project under test plus `BenchmarkDotNet`.
- Set `<RootNamespace>` on the csproj to the **root namespace of the project under test** (e.g. `MyOrg.Elements`) so newly-added benchmarks default to the correct namespace.

```csharp
// Program.cs (root of the .Tests.Performance project)
public static class Program
{
    public static void Main(string[] args) =>
        BenchmarkSwitcher.FromAssembly(typeof(Program).Assembly).Run(args);
}
```

```csharp
// Security/ClaimsPrincipalExtensionsBenchmarks.cs
namespace MyOrg.Elements.Security; // matches the namespace of ClaimsPrincipalExtensions

[MemoryDiagnoser]
public class ClaimsPrincipalExtensionsBenchmarks { /* ... */ }
```

## Naming

- Benchmark class: `{ClassUnderTest}Benchmarks` (e.g. `WorkItemBenchmarks`, `ExpressionEvaluatorBenchmarks`). Mirror the unit-test fixture name with `Benchmarks` instead of `TestFixture`.
- For generic types, keep the source-file naming convention: `RangeOfT.cs` → `RangeOfTBenchmarks.cs`.
- Benchmark method: `{ScenarioOrPath}` — short, noun-phrase, no `Given_/When_/Then_` ceremony. The output table reads better with concise names.
  - ✅ `EvaluateSimpleEquality`, `EvaluateNestedAnd`, `Serialize_Small`, `Serialize_Large`
  - ❌ `Given_Evaluator_Called_When_Expression_Is_Simple_Then_Returns_True`
- Use `[Params]` for input-size axes rather than separate methods when the code path is identical.

## Benchmark class structure

```csharp
[MemoryDiagnoser]
public class ExpressionEvaluatorBenchmarks
{
    private ExpressionEvaluator _evaluator = null!;
    private ConditionExpression _expression = null!;
    private ExpressionEvaluationContext _context = null!;

    [Params(10, 100, 1_000)]
    public int AttributeCount;

    [GlobalSetup]
    public void Setup()
    {
        _evaluator = new ExpressionEvaluator();
        _expression = ExpressionParser.Parse("$subject.role == 'admin'");
        _context = BuildContext(AttributeCount);
    }

    [Benchmark(Baseline = true)]
    public EvaluationResult EvaluateSimpleEquality() => _evaluator.Evaluate(_expression, _context);

    private static ExpressionEvaluationContext BuildContext(int count) { /* ... */ }
}
```

Rules:

- **`[GlobalSetup]` for one-time fixtures**, `[IterationSetup]` only when per-iteration mutation is genuinely required (it adds overhead).
- **Mark exactly one benchmark `Baseline = true`** when comparing variants of the same operation.
- **Return a value from every `[Benchmark]`** so the JIT cannot dead-code-eliminate the work. If the method is genuinely `void`, store the result in a public field instead.
- **No `async void`.** Async benchmarks must return `Task` or `ValueTask`.

## Measurement discipline

- **Run in `Release`.** Configure the project with `<TieredCompilation>true</TieredCompilation>` defaults; do not disable tiered JIT unless you have a specific reason.
- **Warm up before measuring.** BenchmarkDotNet does this by default — do not override warmup/iteration counts unless you can justify the change in a comment.
- **Isolate inputs.** Build inputs in `[GlobalSetup]`; do not allocate in the hot path unless allocation is what you are measuring.
- **Memory matters.** `[MemoryDiagnoser]` is mandatory on every benchmark class. Allocation regressions are first-class failures.
- **No I/O, no clocks, no random sources** in the hot path. Seed any randomness in setup.
- **One concern per benchmark.** Do not combine independent operations in a single `[Benchmark]` method — split them so the report is interpretable.
- **Before/after comparisons** must enable `BenchmarkDotNet.Columns.StatisticalTestColumn` (or equivalent) so changes are reported with statistical significance, not eyeballed deltas.
- **Do not commit benchmark artifacts.** Add `/BenchmarkDotNet.Artifacts/` to `.gitignore` and keep generated reports out of source control.

## What to measure

Every benchmark should produce a number that maps to one of these axes:

| Metric | Captured via | Target |
|---|---|---|
| Throughput | BenchmarkDotNet `Mean` / `Ops/s` | Requests or operations per second at target concurrency |
| Latency | BenchmarkDotNet percentile columns | p50 / p95 / p99 response time |
| Memory | `[MemoryDiagnoser]` (`Allocated`, `Gen0/1/2`) | Allocation rate, GC pressure |
| Database / I/O cost | Custom counters or scoped benchmark inputs | Query execution time, connection-pool utilisation |

## What to benchmark

Benchmark:

- Hot paths identified by profiling or production telemetry.
- APIs with explicit performance contracts (e.g. authorisation evaluators, serialisers, mappers).
- Algorithmic alternatives being compared before adoption.
- Allocation-sensitive code on the request/response path.

Do not benchmark:

- Behavioural correctness — that is the job of unit/integration tests.
- I/O-bound code where the dominant cost is the network or disk (use a load test instead).
- Trivial code with no measurable cost.
- Anything you have not first measured in production or profiled — premature benchmarking is noise.

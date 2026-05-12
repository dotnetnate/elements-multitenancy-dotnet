using BenchmarkDotNet.Attributes;
using MyOrg.Elements.MultiTenancy;

namespace MyOrg.Elements.MultiTenancy.Abstractions.Tests.Benchmark;

[MemoryDiagnoser]
public class MultiTenancyAbstractionsBenchmarks {
    private TenantContextAccessor _accessor = null!;

    [GlobalSetup]
    public void Setup() => _accessor = new TenantContextAccessor();

    [Benchmark]
    public TenantContext CreateTenantContext() => new TenantContext("contoso");

    [Benchmark]
    public ITenantContext GetUnresolved() => TenantContext.Unresolved;

    [Benchmark]
    public bool CreateAndCheckResolved() => new TenantContext("acme").IsResolved;

    [Benchmark]
    public string GetTenantId() => new TenantContext("fabrikam").TenantId;

    [Benchmark]
    public void SetAndGetAccessor() {
        _accessor.TenantContext = new TenantContext("contoso");
        _ = _accessor.TenantContext;
    }

    [Benchmark]
    public ITenantContext? GetAccessorValue() => _accessor.TenantContext;

    [Benchmark(OperationsPerInvoke = 1000)]
    public TenantContext CreateTenantContextBatch() {
        TenantContext last = null!;
        for (int i = 0; i < 1000; i++)
            last = new TenantContext($"tenant{i}");
        return last;
    }
}

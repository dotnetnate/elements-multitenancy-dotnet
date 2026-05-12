using BenchmarkDotNet.Attributes;
using Microsoft.Extensions.DependencyInjection;
using MyOrg.Elements.MultiTenancy.AspNet;

namespace MyOrg.Elements.MultiTenancy.AspNet.Tests.Benchmark;

[MemoryDiagnoser]
public class MultiTenancyAspNetBenchmarks {
    [Benchmark]
    public MultiTenancyOptions CreateDefaultOptions() => new MultiTenancyOptions();

    [Benchmark]
    public MultiTenancyOptions CreateCustomOptions() =>
        new MultiTenancyOptions {
            HeaderName = "X-Tenant-Id",
            ClaimType = "tenant_id",
            QueryStringParameterName = "tenant",
            ResolveFromClaims = true,
            ResolveFromHeader = true,
            ResolveFromHost = false,
            ResolveFromQueryString = true,
        };

    [Benchmark]
    public IServiceCollection RegisterMultiTenancyDefault() {
        var services = new ServiceCollection();
        services.AddElementsMultiTenancy();
        return services;
    }

    [Benchmark]
    public IServiceCollection RegisterMultiTenancyWithOptions() {
        var services = new ServiceCollection();
        services.AddElementsMultiTenancy(o => {
            o.ResolveFromHeader = true;
            o.ResolveFromClaims = true;
            o.HeaderName = "X-Tenant-Id";
        });
        return services;
    }

    [Benchmark]
    public string? ParseHostTenant() {
        var options = new MultiTenancyOptions();
        return options.HostParser("contoso.example.com");
    }
}

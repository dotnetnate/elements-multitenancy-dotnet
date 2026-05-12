using BenchmarkDotNet.Attributes;
using Microsoft.Extensions.DependencyInjection;
using MyOrg.Elements.MultiTenancy;
using MyOrg.Elements.MultiTenancy.DependencyInjection;

namespace MyOrg.Elements.MultiTenancy.Extensions.DependencyInjection.Tests.Benchmark;

[MemoryDiagnoser]
public class MultiTenancyDiBenchmarks {
    [Benchmark]
    public IServiceCollection RegisterKeyedTenantServiceResolver() {
        var services = new ServiceCollection();
        services.AddKeyedTenantServiceResolver<IFakeService>();
        return services;
    }

    [Benchmark]
    public IServiceCollection RegisterFactoryTenantServiceResolver() {
        var services = new ServiceCollection();
        services.AddFactoryTenantServiceResolver<IFakeService>(b => {
            b.ForTenant("contoso", _ => new FakeService("contoso"));
            b.ForTenant("fabrikam", _ => new FakeService("fabrikam"));
        });
        return services;
    }

    [Benchmark]
    public IServiceCollection RegisterBothResolvers() {
        var services = new ServiceCollection();
        services.AddKeyedTenantServiceResolver<IFakeService>();
        services.AddFactoryTenantServiceResolver<IOtherFakeService>(b =>
            b.ForTenant("acme", _ => new OtherFakeService()));
        return services;
    }

    private interface IFakeService { string Name { get; } }
    private interface IOtherFakeService { }

    private sealed class FakeService(string name) : IFakeService {
        public string Name => name;
    }

    private sealed class OtherFakeService : IOtherFakeService { }
}

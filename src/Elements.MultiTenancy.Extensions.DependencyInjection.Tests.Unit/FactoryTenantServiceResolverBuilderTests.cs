using Microsoft.Extensions.DependencyInjection;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy;
using MyOrg.Elements.MultiTenancy.DependencyInjection;

namespace Elements.MultiTenancy.Extensions.DependencyInjection.Tests.Unit;

[TestClass]
public class FactoryTenantServiceResolverBuilderTests {
    private interface ITestService {
        string GetValue();
    }

    private class TestService : ITestService {
        private readonly string _value;
        public TestService(string value) => _value = value;
        public string GetValue() => _value;
    }

    [TestMethod]
    public void ForTenant_RegistersFactory_ResolvedByTenantId() {
        // Arrange
        var accessor = new TenantContextAccessor();
        var services = new ServiceCollection();
        services.AddSingleton<ITenantContextAccessor>(accessor);
        services.AddFactoryTenantServiceResolver<ITestService>(builder => {
            builder.ForTenant("tenant1", sp => new TestService("value1"));
        });

        using var provider = services.BuildServiceProvider();
        var resolver = provider.GetRequiredService<ITenantServiceResolver<ITestService>>();

        // Act
        accessor.TenantContext = new TenantContext("tenant1");
        var service = resolver.ResolveCurrent();

        // Assert
        Assert.AreEqual("value1", service.GetValue());
    }

    [TestMethod]
    public void ForTenant_SupportsChainingMultipleTenants() {
        // Arrange
        var accessor = new TenantContextAccessor();
        var services = new ServiceCollection();
        services.AddSingleton<ITenantContextAccessor>(accessor);
        services.AddFactoryTenantServiceResolver<ITestService>(builder => {
            builder
                .ForTenant("tenant1", sp => new TestService("v1"))
                .ForTenant("tenant2", sp => new TestService("v2"))
                .ForTenant("tenant3", sp => new TestService("v3"));
        });

        using var provider = services.BuildServiceProvider();
        var resolver = provider.GetRequiredService<ITenantServiceResolver<ITestService>>();

        // Act
        accessor.TenantContext = new TenantContext("tenant2");
        var service = resolver.ResolveCurrent();

        // Assert
        Assert.AreEqual("v2", service.GetValue());
    }
}
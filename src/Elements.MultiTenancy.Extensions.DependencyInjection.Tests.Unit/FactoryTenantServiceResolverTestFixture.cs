using FakeItEasy;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy;
using MyOrg.Elements.MultiTenancy.DependencyInjection;

namespace Elements.MultiTenancy.Extensions.DependencyInjection.Tests.Unit;

[TestClass]
public class FactoryTenantServiceResolverTestFixture {
    private interface ITestService {
        string GetValue();
    }

    private class TestService : ITestService {
        private readonly string _tenantId;
        public TestService(string tenantId) => _tenantId = tenantId;
        public string GetValue() => _tenantId;
    }

    [TestMethod]
    public void Given_Factory_Resolver_When_Factory_Registered_Then_Creates_Service() {
        // Arrange
        var services = new ServiceCollection();
        var fakeAccessor = A.Fake<ITenantContextAccessor>();
        A.CallTo(() => fakeAccessor.TenantContext).Returns(new TenantContext("tenant1"));

        var serviceProvider = services.BuildServiceProvider();
        var resolver = new FactoryTenantServiceResolver<ITestService>(serviceProvider, fakeAccessor);
        resolver.RegisterFactory("tenant1", sp => new TestService("tenant1"));

        // Act
        var service = resolver.ResolveCurrent();

        // Assert
        Assert.IsNotNull(service);
        Assert.AreEqual("tenant1", service.GetValue());
    }

    [TestMethod]
    public void Given_Factory_Resolver_When_Tenant_Changes_Then_Returns_Different_Service() {
        // Arrange
        var services = new ServiceCollection();
        var fakeAccessor = A.Fake<ITenantContextAccessor>();
        var serviceProvider = services.BuildServiceProvider();
        var resolver = new FactoryTenantServiceResolver<ITestService>(serviceProvider, fakeAccessor);

        resolver.RegisterFactory("tenant1", sp => new TestService("tenant1"));
        resolver.RegisterFactory("tenant2", sp => new TestService("tenant2"));

        // Act
        A.CallTo(() => fakeAccessor.TenantContext).Returns(new TenantContext("tenant1"));
        var service1 = resolver.ResolveCurrent();

        A.CallTo(() => fakeAccessor.TenantContext).Returns(new TenantContext("tenant2"));
        var service2 = resolver.ResolveCurrent();

        // Assert
        Assert.AreEqual("tenant1", service1.GetValue());
        Assert.AreEqual("tenant2", service2.GetValue());
    }
}
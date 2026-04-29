using FakeItEasy;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy;
using MyOrg.Elements.MultiTenancy.DependencyInjection;

namespace Elements.MultiTenancy.Extensions.DependencyInjection.Tests.Unit;

[TestClass]
public class KeyedTenantServiceResolverTestFixture {
    private interface ITestService {
    }
    private class TestService : ITestService {
    }

    [TestMethod]
    public void Given_Keyed_Resolver_When_Service_Registered_Then_Resolves_By_Tenant_Key() {
        // Arrange
        var services = new ServiceCollection();
        services.AddKeyedSingleton<ITestService, TestService>("tenant1");

        var fakeAccessor = A.Fake<ITenantContextAccessor>();
        A.CallTo(() => fakeAccessor.TenantContext).Returns(new TenantContext("tenant1"));

        var serviceProvider = services.BuildServiceProvider();
        var resolver = new KeyedTenantServiceResolver<ITestService>(serviceProvider, fakeAccessor);

        // Act
        var service = resolver.ResolveCurrent();

        // Assert
        Assert.IsNotNull(service);
    }
}
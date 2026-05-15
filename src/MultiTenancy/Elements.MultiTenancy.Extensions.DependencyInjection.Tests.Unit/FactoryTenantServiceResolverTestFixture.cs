using FakeItEasy;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy;
using MyOrg.Elements.MultiTenancy.DependencyInjection;

namespace Elements.MultiTenancy.Extensions.DependencyInjection.Tests.Unit;

[TestClass]
public class FactoryTenantServiceResolverTestFixture
{
    private interface ITestService
    {
        string GetValue();
    }

    private class TestService : ITestService
    {
        private readonly string _tenantId;
        public TestService(string tenantId) => _tenantId = tenantId;
        public string GetValue() => _tenantId;
    }

    [TestMethod]
    public void Given_Factory_Resolver_When_Factory_Registered_Then_Creates_Service()
    {
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
    public void Given_Factory_Resolver_When_Tenant_Changes_Then_Returns_Different_Service()
    {
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

    [TestMethod]
    public void Given_Constructor_Called_When_ServiceProvider_Is_Null_Then_Throws()
    {
        // Arrange
        var fakeAccessor = A.Fake<ITenantContextAccessor>();

        // Act & Assert
        Assert.ThrowsExactly<ArgumentNullException>(() => new FactoryTenantServiceResolver<ITestService>(null!, fakeAccessor));
    }

    [TestMethod]
    public void Given_Constructor_Called_When_TenantContextAccessor_Is_Null_Then_Throws()
    {
        // Arrange
        var serviceProvider = new ServiceCollection().BuildServiceProvider();

        // Act & Assert
        Assert.ThrowsExactly<ArgumentNullException>(() => new FactoryTenantServiceResolver<ITestService>(serviceProvider, null!));
    }

    [TestMethod]
    public void Given_RegisterFactory_Called_When_TenantId_Is_Whitespace_Then_Throws()
    {
        // Arrange
        var resolver = CreateResolver();

        // Act & Assert
        Assert.ThrowsExactly<ArgumentException>(() => resolver.RegisterFactory("   ", _ => new TestService("tenant1")));
    }

    [TestMethod]
    public void Given_RegisterFactory_Called_When_Factory_Is_Null_Then_Throws()
    {
        // Arrange
        var resolver = CreateResolver();

        // Act & Assert
        Assert.ThrowsExactly<ArgumentNullException>(() => resolver.RegisterFactory("tenant1", null!));
    }

    [TestMethod]
    public void Given_Resolve_Called_When_TenantId_Is_Whitespace_Then_Throws()
    {
        // Arrange
        var resolver = CreateResolver();

        // Act & Assert
        Assert.ThrowsExactly<ArgumentException>(() => resolver.Resolve("   "));
    }

    [TestMethod]
    public void Given_Resolve_Called_When_Factory_Is_Not_Registered_Then_Throws()
    {
        // Arrange
        var resolver = CreateResolver();

        // Act & Assert
        Assert.ThrowsExactly<InvalidOperationException>(() => resolver.Resolve("tenant1"));
    }

    [TestMethod]
    public void Given_Resolve_Current_Called_When_Tenant_Context_Is_Null_Then_Throws()
    {
        // Arrange
        var resolver = CreateResolver();

        // Act & Assert
        Assert.ThrowsExactly<InvalidOperationException>(() => resolver.ResolveCurrent());
    }

    [TestMethod]
    public void Given_Resolve_Current_Called_When_Tenant_Context_Is_Unresolved_Then_Throws()
    {
        // Arrange
        var fakeAccessor = A.Fake<ITenantContextAccessor>();
        A.CallTo(() => fakeAccessor.TenantContext).Returns(TenantContext.Unresolved);
        var serviceProvider = new ServiceCollection().BuildServiceProvider();
        var resolver = new FactoryTenantServiceResolver<ITestService>(serviceProvider, fakeAccessor);

        // Act & Assert
        Assert.ThrowsExactly<InvalidOperationException>(() => resolver.ResolveCurrent());
    }

    private static FactoryTenantServiceResolver<ITestService> CreateResolver()
    {
        var serviceProvider = new ServiceCollection().BuildServiceProvider();
        var fakeAccessor = A.Fake<ITenantContextAccessor>();
        return new FactoryTenantServiceResolver<ITestService>(serviceProvider, fakeAccessor);
    }
}
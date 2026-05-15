using FakeItEasy;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy;
using MyOrg.Elements.MultiTenancy.DependencyInjection;

namespace Elements.MultiTenancy.Extensions.DependencyInjection.Tests.Unit;

[TestClass]
public class KeyedTenantServiceResolverTestFixture
{
    private interface ITestService
    {
    }
    private class TestService : ITestService
    {
    }

    [TestMethod]
    public void Given_Keyed_Resolver_When_Service_Registered_Then_Resolves_By_Tenant_Key()
    {
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

    [TestMethod]
    public void Given_Constructor_Called_When_ServiceProvider_Is_Null_Then_Throws()
    {
        // Arrange
        var fakeAccessor = A.Fake<ITenantContextAccessor>();

        // Act & Assert
        Assert.ThrowsExactly<ArgumentNullException>(() => new KeyedTenantServiceResolver<ITestService>(null!, fakeAccessor));
    }

    [TestMethod]
    public void Given_Constructor_Called_When_TenantContextAccessor_Is_Null_Then_Throws()
    {
        // Arrange
        var serviceProvider = new ServiceCollection().BuildServiceProvider();

        // Act & Assert
        Assert.ThrowsExactly<ArgumentNullException>(() => new KeyedTenantServiceResolver<ITestService>(serviceProvider, null!));
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
    public void Given_Resolve_Called_When_Service_Is_Not_Registered_Then_Throws()
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
        var resolver = new KeyedTenantServiceResolver<ITestService>(serviceProvider, fakeAccessor);

        // Act & Assert
        Assert.ThrowsExactly<InvalidOperationException>(() => resolver.ResolveCurrent());
    }

    private static KeyedTenantServiceResolver<ITestService> CreateResolver()
    {
        var serviceProvider = new ServiceCollection().BuildServiceProvider();
        var fakeAccessor = A.Fake<ITenantContextAccessor>();
        return new KeyedTenantServiceResolver<ITestService>(serviceProvider, fakeAccessor);
    }
}
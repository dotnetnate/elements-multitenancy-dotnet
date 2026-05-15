using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy;
using MyOrg.Elements.MultiTenancy.AspNet;

namespace Elements.MultiTenancy.Extensions.AspNet.Tests.Unit;

[TestClass]
public class ServiceCollectionExtensionsTests
{
    [TestMethod]
    public void AddElementsMultiTenancy_RegistersCoreServices()
    {
        // Arrange
        var services = new ServiceCollection();

        // Act
        services.AddElementsMultiTenancy();
        var provider = services.BuildServiceProvider();

        // Assert
        Assert.IsNotNull(provider.GetService<ITenantContextAccessor>());
        Assert.IsNotNull(provider.GetService<ITenantIdParser>());
        Assert.IsNotNull(provider.GetService<ITenantResolver<HttpContext>>());
    }

    [TestMethod]
    public void AddElementsMultiTenancy_DefaultOptions_RegistersClaimsHeaderHostStrategies()
    {
        // Arrange
        var services = new ServiceCollection();

        // Act
        services.AddElementsMultiTenancy();
        var provider = services.BuildServiceProvider();

        // Assert - default options enable Claims, Header, Host
        var strategies = provider.GetServices<ITenantResolutionStrategy<HttpContext>>().ToList();
        Assert.AreEqual(3, strategies.Count);
        Assert.IsTrue(strategies.Any(s => s is ClaimsTenantResolutionStrategy));
        Assert.IsTrue(strategies.Any(s => s is HeaderTenantResolutionStrategy));
        Assert.IsTrue(strategies.Any(s => s is HostTenantResolutionStrategy));
    }

    [TestMethod]
    public void AddElementsMultiTenancy_WithQueryString_RegistersQueryStringStrategy()
    {
        // Arrange
        var services = new ServiceCollection();

        // Act
        services.AddElementsMultiTenancy(opts => opts.ResolveFromQueryString = true);
        var provider = services.BuildServiceProvider();

        // Assert
        var strategies = provider.GetServices<ITenantResolutionStrategy<HttpContext>>().ToList();
        Assert.AreEqual(4, strategies.Count);
        Assert.IsTrue(strategies.Any(s => s is QueryStringTenantResolutionStrategy));
    }

    [TestMethod]
    public void AddElementsMultiTenancy_WithAllDisabled_RegistersNoStrategies()
    {
        // Arrange
        var services = new ServiceCollection();

        // Act
        services.AddElementsMultiTenancy(opts =>
        {
            opts.ResolveFromClaims = false;
            opts.ResolveFromHeader = false;
            opts.ResolveFromHost = false;
            opts.ResolveFromQueryString = false;
        });
        var provider = services.BuildServiceProvider();

        // Assert
        var strategies = provider.GetServices<ITenantResolutionStrategy<HttpContext>>().ToList();
        Assert.AreEqual(0, strategies.Count);
    }

    [TestMethod]
    public void AddElementsMultiTenancyWithGuidParser_RegistersGuidParser()
    {
        // Arrange
        var services = new ServiceCollection();

        // Act
        services.AddElementsMultiTenancyWithGuidParser();
        var provider = services.BuildServiceProvider();

        // Assert
        var parser = provider.GetService<ITenantIdParser>();
        Assert.IsInstanceOfType<GuidTenantIdParser>(parser);
    }

    [TestMethod]
    public void AddElementsMultiTenancy_DefaultParser_IsDefaultTenantIdParser()
    {
        // Arrange
        var services = new ServiceCollection();

        // Act
        services.AddElementsMultiTenancy();
        var provider = services.BuildServiceProvider();

        // Assert
        var parser = provider.GetService<ITenantIdParser>();
        Assert.IsInstanceOfType<DefaultTenantIdParser>(parser);
    }

    [TestMethod]
    public void UseElementsMultiTenancy_When_Called_Then_Returns_Same_Application_Builder()
    {
        // Arrange
        var services = new ServiceCollection();
        services.AddLogging();
        services.AddElementsMultiTenancy();
        using var provider = services.BuildServiceProvider();
        var app = new ApplicationBuilder(provider);

        // Act
        var result = app.UseElementsMultiTenancy();

        // Assert
        Assert.AreSame(app, result);
    }
}
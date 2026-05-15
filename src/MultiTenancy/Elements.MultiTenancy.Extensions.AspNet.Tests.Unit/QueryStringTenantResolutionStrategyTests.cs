using Microsoft.AspNetCore.Http;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy.AspNet;

namespace Elements.MultiTenancy.Extensions.AspNet.Tests.Unit;

[TestClass]
public class QueryStringTenantResolutionStrategyTests
{
    [TestMethod]
    public async Task ResolveAsync_WithValidQueryParameter_ReturnsTenantId()
    {
        // Arrange
        var options = new MultiTenancyOptions { QueryStringParameterName = "tenant" };
        var strategy = new QueryStringTenantResolutionStrategy(options);
        var context = new DefaultHttpContext();
        context.Request.QueryString = new QueryString("?tenant=tenant123");

        // Act
        var result = await strategy.ResolveAsync(context);

        // Assert
        Assert.AreEqual("tenant123", result);
    }

    [TestMethod]
    public async Task ResolveAsync_WithoutQueryParameter_ReturnsNull()
    {
        // Arrange
        var options = new MultiTenancyOptions { QueryStringParameterName = "tenant" };
        var strategy = new QueryStringTenantResolutionStrategy(options);
        var context = new DefaultHttpContext();

        // Act
        var result = await strategy.ResolveAsync(context);

        // Assert
        Assert.IsNull(result);
    }

    [TestMethod]
    public async Task ResolveAsync_WithCustomParameterName_UsesCustomName()
    {
        // Arrange
        var options = new MultiTenancyOptions { QueryStringParameterName = "org" };
        var strategy = new QueryStringTenantResolutionStrategy(options);
        var context = new DefaultHttpContext();
        context.Request.QueryString = new QueryString("?org=myorg");

        // Act
        var result = await strategy.ResolveAsync(context);

        // Assert
        Assert.AreEqual("myorg", result);
    }

    [TestMethod]
    public void Priority_Returns40()
    {
        // Arrange
        var options = new MultiTenancyOptions();
        var strategy = new QueryStringTenantResolutionStrategy(options);

        // Assert
        Assert.AreEqual(40, strategy.Priority);
    }

    [TestMethod]
    public void Constructor_When_Options_Is_Null_Then_Throws()
    {
        // Act & Assert
        Assert.ThrowsExactly<ArgumentNullException>(() => new QueryStringTenantResolutionStrategy(null!));
    }
}
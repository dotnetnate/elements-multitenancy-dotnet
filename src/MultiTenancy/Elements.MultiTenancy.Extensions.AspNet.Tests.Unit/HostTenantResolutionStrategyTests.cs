using Microsoft.AspNetCore.Http;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy.AspNet;

namespace Elements.MultiTenancy.Extensions.AspNet.Tests.Unit;

[TestClass]
public class HostTenantResolutionStrategyTests
{
    [TestMethod]
    public async Task ResolveAsync_WithSubdomain_ReturnsTenantId()
    {
        // Arrange
        var options = new MultiTenancyOptions();
        var strategy = new HostTenantResolutionStrategy(options);
        var context = new DefaultHttpContext();
        context.Request.Host = new HostString("tenant123.example.com");

        // Act
        var result = await strategy.ResolveAsync(context);

        // Assert
        Assert.AreEqual("tenant123", result);
    }

    [TestMethod]
    public async Task ResolveAsync_WithoutSubdomain_ReturnsNull()
    {
        // Arrange
        var options = new MultiTenancyOptions();
        var strategy = new HostTenantResolutionStrategy(options);
        var context = new DefaultHttpContext();
        context.Request.Host = new HostString("example.com");

        // Act
        var result = await strategy.ResolveAsync(context);

        // Assert
        Assert.IsNull(result);
    }

    [TestMethod]
    public async Task ResolveAsync_WithPort_ExtractsTenantCorrectly()
    {
        // Arrange
        var options = new MultiTenancyOptions();
        var strategy = new HostTenantResolutionStrategy(options);
        var context = new DefaultHttpContext();
        context.Request.Host = new HostString("tenant456.example.com", 8080);

        // Act
        var result = await strategy.ResolveAsync(context);

        // Assert
        Assert.AreEqual("tenant456", result);
    }

    [TestMethod]
    public async Task ResolveAsync_WithCustomParser_UsesCustomLogic()
    {
        // Arrange
        var options = new MultiTenancyOptions
        {
            HostParser = host => host.Split('.')[^2] // Get second-to-last segment
        };
        var strategy = new HostTenantResolutionStrategy(options);
        var context = new DefaultHttpContext();
        context.Request.Host = new HostString("sub.tenant789.com");

        // Act
        var result = await strategy.ResolveAsync(context);

        // Assert
        Assert.AreEqual("tenant789", result);
    }

    [TestMethod]
    public void Priority_ReturnsExpectedValue()
    {
        // Arrange
        var options = new MultiTenancyOptions();
        var strategy = new HostTenantResolutionStrategy(options);

        // Assert
        Assert.AreEqual(30, strategy.Priority);
    }

    [TestMethod]
    public void Constructor_When_Options_Is_Null_Then_Throws()
    {
        // Act & Assert
        Assert.ThrowsExactly<ArgumentNullException>(() => new HostTenantResolutionStrategy(null!));
    }

    [TestMethod]
    public void DefaultHostParser_When_Host_Is_Whitespace_Then_Returns_Null()
    {
        // Arrange
        var options = new MultiTenancyOptions();

        // Act
        var result = options.HostParser("   ");

        // Assert
        Assert.IsNull(result);
    }

    [TestMethod]
    public void DefaultHostParser_When_Host_Contains_Port_Then_Returns_Subdomain()
    {
        // Arrange
        var options = new MultiTenancyOptions();

        // Act
        var result = options.HostParser("tenant.example.com:8080");

        // Assert
        Assert.AreEqual("tenant", result);
    }
}
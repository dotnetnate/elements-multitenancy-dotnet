using Microsoft.AspNetCore.Http;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy.AspNet;

namespace Elements.MultiTenancy.Extensions.AspNet.Tests.Unit;

[TestClass]
public class HeaderTenantResolutionStrategyTests {
    [TestMethod]
    public async Task ResolveAsync_WithValidHeader_ReturnsTenantId() {
        // Arrange
        var options = new MultiTenancyOptions { HeaderName = "X-Tenant-Id" };
        var strategy = new HeaderTenantResolutionStrategy(options);
        var context = new DefaultHttpContext();
        context.Request.Headers["X-Tenant-Id"] = "tenant123";

        // Act
        var result = await strategy.ResolveAsync(context);

        // Assert
        Assert.AreEqual("tenant123", result);
    }

    [TestMethod]
    public async Task ResolveAsync_WithoutHeader_ReturnsNull() {
        // Arrange
        var options = new MultiTenancyOptions { HeaderName = "X-Tenant-Id" };
        var strategy = new HeaderTenantResolutionStrategy(options);
        var context = new DefaultHttpContext();

        // Act
        var result = await strategy.ResolveAsync(context);

        // Assert
        Assert.IsNull(result);
    }

    [TestMethod]
    public void Priority_ReturnsExpectedValue() {
        // Arrange
        var options = new MultiTenancyOptions();
        var strategy = new HeaderTenantResolutionStrategy(options);

        // Assert
        Assert.AreEqual(20, strategy.Priority);
    }
}
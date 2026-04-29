using Microsoft.AspNetCore.Http;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy.AspNet;
using MyOrg.Elements.Security.Identity;
using System.Security.Claims;

namespace Elements.MultiTenancy.Extensions.AspNet.Tests.Unit;

[TestClass]
public class ClaimsTenantResolutionStrategyTests {
    [TestMethod]
    public async Task ResolveAsync_WithValidTenantClaim_ReturnsTenantId() {
        // Arrange
        var options = new MultiTenancyOptions();
        var claimsConfig = new WellKnownClaimsConfiguration();
        var strategy = new ClaimsTenantResolutionStrategy(options, claimsConfig);

        var claims = new[] { new Claim("tenant_id", "tenant123") };
        var identity = new ClaimsIdentity(claims, "TestAuth");
        var context = new DefaultHttpContext { User = new ClaimsPrincipal(identity) };

        // Act
        var result = await strategy.ResolveAsync(context);

        // Assert
        Assert.AreEqual("tenant123", result);
    }

    [TestMethod]
    public async Task ResolveAsync_WithCustomClaimType_UsesCustomType() {
        // Arrange
        var options = new MultiTenancyOptions { ClaimType = "org_id" };
        var claimsConfig = new WellKnownClaimsConfiguration();
        var strategy = new ClaimsTenantResolutionStrategy(options, claimsConfig);

        var claims = new[] { new Claim("org_id", "org456") };
        var identity = new ClaimsIdentity(claims, "TestAuth");
        var context = new DefaultHttpContext { User = new ClaimsPrincipal(identity) };

        // Act
        var result = await strategy.ResolveAsync(context);

        // Assert
        Assert.AreEqual("org456", result);
    }

    [TestMethod]
    public async Task ResolveAsync_WithUnauthenticatedUser_ReturnsNull() {
        // Arrange
        var options = new MultiTenancyOptions();
        var claimsConfig = new WellKnownClaimsConfiguration();
        var strategy = new ClaimsTenantResolutionStrategy(options, claimsConfig);
        var context = new DefaultHttpContext();

        // Act
        var result = await strategy.ResolveAsync(context);

        // Assert
        Assert.IsNull(result);
    }

    [TestMethod]
    public async Task ResolveAsync_WithNoTenantClaim_ReturnsNull() {
        // Arrange
        var options = new MultiTenancyOptions();
        var claimsConfig = new WellKnownClaimsConfiguration();
        var strategy = new ClaimsTenantResolutionStrategy(options, claimsConfig);

        var claims = new[] { new Claim("sub", "user1") };
        var identity = new ClaimsIdentity(claims, "TestAuth");
        var context = new DefaultHttpContext { User = new ClaimsPrincipal(identity) };

        // Act
        var result = await strategy.ResolveAsync(context);

        // Assert
        Assert.IsNull(result);
    }

    [TestMethod]
    public void Priority_Returns10() {
        // Arrange
        var options = new MultiTenancyOptions();
        var claimsConfig = new WellKnownClaimsConfiguration();
        var strategy = new ClaimsTenantResolutionStrategy(options, claimsConfig);

        // Assert
        Assert.AreEqual(10, strategy.Priority);
    }
}
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy;

namespace Elements.MultiTenancy.Abstractions.Tests.Unit;

[TestClass]
public class TenantContextTests {
    [TestMethod]
    public void Constructor_WithValidTenantId_CreatesTenantContext() {
        // Arrange
        var tenantId = "tenant123";

        // Act
        var context = new TenantContext(tenantId);

        // Assert
        Assert.AreEqual(tenantId, context.TenantId);
        Assert.IsTrue(context.IsResolved);
    }

    [TestMethod]
    public void Constructor_WithNullTenantId_ThrowsArgumentException() {
        // Act
        try {
            _ = new TenantContext(null!);
            Assert.Fail("Expected ArgumentException was not thrown.");
        }
        catch (ArgumentException) {
            // Expected exception
        }
    }

    [TestMethod]
    public void Constructor_WithWhitespaceTenantId_ThrowsArgumentException() {
        // Act
        try {
            _ = new TenantContext("   ");
            Assert.Fail("Expected ArgumentException was not thrown.");
        }
        catch (ArgumentException) {
            // Expected exception
        }
    }

    [TestMethod]
    public void Unresolved_ReturnsUnresolvedContext() {
        // Act
        var context = TenantContext.Unresolved;

        // Assert
        Assert.IsFalse(context.IsResolved);
        Assert.AreEqual(string.Empty, context.TenantId);
    }
}
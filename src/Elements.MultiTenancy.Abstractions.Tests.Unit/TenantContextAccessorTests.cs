using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy;

namespace Elements.MultiTenancy.Abstractions.Tests.Unit;

[TestClass]
public class TenantContextAccessorTests {
    [TestMethod]
    public void TenantContext_GetSet_WorksCorrectly() {
        // Arrange
        var accessor = new TenantContextAccessor();
        var context = new TenantContext("tenant123");

        // Act
        accessor.TenantContext = context;
        var retrieved = accessor.TenantContext;

        // Assert
        Assert.AreEqual(context, retrieved);
        Assert.AreEqual("tenant123", retrieved?.TenantId);
    }

    [TestMethod]
    public void TenantContext_DefaultValue_IsNull() {
        // Arrange
        var accessor = new TenantContextAccessor();

        // Act
        var context = accessor.TenantContext;

        // Assert
        Assert.IsNull(context);
    }

    [TestMethod]
    public async Task TenantContext_IsolatedBetweenAsyncContexts() {
        // Arrange
        var accessor = new TenantContextAccessor();

        // Act & Assert
        var task1 = Task.Run(() => {
            accessor.TenantContext = new TenantContext("tenant1");
            Thread.Sleep(50);
            Assert.AreEqual("tenant1", accessor.TenantContext?.TenantId);
        });

        var task2 = Task.Run(() => {
            accessor.TenantContext = new TenantContext("tenant2");
            Thread.Sleep(50);
            Assert.AreEqual("tenant2", accessor.TenantContext?.TenantId);
        });

        await Task.WhenAll(task1, task2);
    }
}
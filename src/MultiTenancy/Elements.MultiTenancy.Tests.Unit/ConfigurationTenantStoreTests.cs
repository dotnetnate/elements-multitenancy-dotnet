using Microsoft.Extensions.Configuration;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy;

namespace Elements.MultiTenancy.Abstractions.Tests.Unit;

[TestClass]
public class ConfigurationTenantStoreTests {
    private sealed class TestConfiguration {
        public string? Name { get; set; } = string.Empty;
        public string? ConnectionString { get; set; } = string.Empty;
    }

    [TestMethod]
    public async Task GetConfigurationAsync_ExistingTenant_ReturnsConfiguration() {
        // Arrange
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?> {
                ["Tenants:tenant1:Name"] = "Tenant One",
                ["Tenants:tenant1:ConnectionString"] = "Server=db1;..."
            })
            .Build();

        var store = new ConfigurationTenantStore<TestConfiguration>(config);

        // Act
        var result = await store.GetConfigurationAsync("tenant1");

        // Assert
        Assert.IsNotNull(result);
        Assert.AreEqual("Tenant One", result.Name);
        Assert.AreEqual("Server=db1;...", result.ConnectionString);
    }

    [TestMethod]
    public async Task GetConfigurationAsync_NonexistentTenant_ReturnsNull() {
        // Arrange
        var config = new ConfigurationBuilder().Build();
        var store = new ConfigurationTenantStore<TestConfiguration>(config);

        // Act
        var result = await store.GetConfigurationAsync("nonexistent");

        // Assert
        Assert.IsNull(result);
    }

    [TestMethod]
    public async Task ExistsAsync_ExistingTenant_ReturnsTrue() {
        // Arrange
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?> {
                ["Tenants:tenant2:Name"] = "Tenant Two"
            })
            .Build();

        var store = new ConfigurationTenantStore<TestConfiguration>(config);

        // Act
        var exists = await store.ExistsAsync("tenant2");

        // Assert
        Assert.IsTrue(exists);
    }

    [TestMethod]
    public async Task ExistsAsync_NonexistentTenant_ReturnsFalse() {
        // Arrange
        var config = new ConfigurationBuilder().Build();
        var store = new ConfigurationTenantStore<TestConfiguration>(config);

        // Act
        var exists = await store.ExistsAsync("nonexistent");

        // Assert
        Assert.IsFalse(exists);
    }

    [TestMethod]
    public void GetAllTenantIds_WithMultipleTenants_ReturnsAllIds() {
        // Arrange
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?> {
                ["Tenants:tenant1:Name"] = "Tenant One",
                ["Tenants:tenant2:Name"] = "Tenant Two",
                ["Tenants:tenant3:Name"] = "Tenant Three"
            })
            .Build();

        var store = new ConfigurationTenantStore<TestConfiguration>(config);

        // Act
        var tenantIds = store.GetAllTenantIds().ToList();

        // Assert
        Assert.HasCount(3, tenantIds);
        Assert.Contains("tenant1", tenantIds);
        Assert.Contains("tenant2", tenantIds);
        Assert.Contains("tenant3", tenantIds);
    }
}
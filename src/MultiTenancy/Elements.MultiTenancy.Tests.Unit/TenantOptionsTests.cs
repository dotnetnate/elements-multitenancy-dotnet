using Microsoft.Extensions.Options;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy;

namespace Elements.MultiTenancy.Abstractions.Tests.Unit;

[TestClass]
public class TenantOptionsTests {
    private class TestOptions {
        public string ConnectionString { get; set; } = "";
    }

    [TestMethod]
    public void Value_ReturnsTenantSpecificOptions() {
        // Arrange
        var accessor = new TenantContextAccessor();
        accessor.TenantContext = new TenantContext("tenant1");

        var monitor = new TestOptionsMonitor<TestOptions>(new TestOptions());
        monitor.Set("tenant1", new TestOptions { ConnectionString = "Server=sql1" });

        var tenantOptions = new TenantOptions<TestOptions>(monitor, accessor);

        // Act
        var value = tenantOptions.Value;

        // Assert
        Assert.AreEqual("Server=sql1", value.ConnectionString);
    }

    [TestMethod]
    public void Value_DifferentTenants_ReturnDifferentOptions() {
        // Arrange
        var accessor = new TenantContextAccessor();
        var monitor = new TestOptionsMonitor<TestOptions>(new TestOptions());
        monitor.Set("tenant1", new TestOptions { ConnectionString = "Server=sql1" });
        monitor.Set("tenant2", new TestOptions { ConnectionString = "Server=sql2" });

        var tenantOptions = new TenantOptions<TestOptions>(monitor, accessor);

        // Act & Assert - tenant1
        accessor.TenantContext = new TenantContext("tenant1");
        Assert.AreEqual("Server=sql1", tenantOptions.Value.ConnectionString);

        // Act & Assert - tenant2
        accessor.TenantContext = new TenantContext("tenant2");
        Assert.AreEqual("Server=sql2", tenantOptions.Value.ConnectionString);
    }

    [TestMethod]
    public void Value_NoTenantContext_ThrowsInvalidOperationException() {
        // Arrange
        var accessor = new TenantContextAccessor();
        var monitor = new TestOptionsMonitor<TestOptions>(new TestOptions());
        var tenantOptions = new TenantOptions<TestOptions>(monitor, accessor);

        // Act & Assert
        Assert.ThrowsExactly<InvalidOperationException>(() => _ = tenantOptions.Value);
    }

    [TestMethod]
    public void Value_UnresolvedTenantContext_ThrowsInvalidOperationException() {
        // Arrange
        var accessor = new TenantContextAccessor();
        accessor.TenantContext = TenantContext.Unresolved;
        var monitor = new TestOptionsMonitor<TestOptions>(new TestOptions());
        var tenantOptions = new TenantOptions<TestOptions>(monitor, accessor);

        // Act & Assert
        Assert.ThrowsExactly<InvalidOperationException>(() => _ = tenantOptions.Value);
    }

    [TestMethod]
    public void Constructor_NullMonitor_ThrowsArgumentNullException() {
        // Arrange
        var accessor = new TenantContextAccessor();

        // Act & Assert
        Assert.ThrowsExactly<ArgumentNullException>(
            () => new TenantOptions<TestOptions>(null!, accessor));
    }

    [TestMethod]
    public void Constructor_NullAccessor_ThrowsArgumentNullException() {
        // Arrange
        var monitor = new TestOptionsMonitor<TestOptions>(new TestOptions());

        // Act & Assert
        Assert.ThrowsExactly<ArgumentNullException>(
            () => new TenantOptions<TestOptions>(monitor, null!));
    }

    private sealed class TestOptionsMonitor<T> : IOptionsMonitor<T> {
        private readonly Dictionary<string, T> _namedOptions = new(StringComparer.OrdinalIgnoreCase);
        private readonly T _default;

        public TestOptionsMonitor(T defaultValue) => _default = defaultValue;

        public T CurrentValue => _default;

        public T Get(string? name) {
            if (string.IsNullOrEmpty(name) || name == Options.DefaultName) {
                return _default;
            }

            return _namedOptions.TryGetValue(name, out var value) ? value : _default;
        }

        public IDisposable? OnChange(Action<T, string?> listener) => null;

        public void Set(string name, T value) => _namedOptions[name] = value;
    }
}
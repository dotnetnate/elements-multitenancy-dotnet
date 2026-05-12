using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy;

namespace Elements.MultiTenancy.Abstractions.Tests.Unit;

[TestClass]
public class TenantResolverTests {
    [TestMethod]
    public async Task ResolveAsync_WithValidStrategy_ReturnsTenantContext() {
        // Arrange
        var strategy = new TestTenantResolutionStrategy("tenant123", priority: 10);
        var parser = new DefaultTenantIdParser();
        var resolver = new TenantResolver<TestContext>(new[] { strategy }, parser);

        // Act
        var result = await resolver.ResolveAsync(new TestContext());

        // Assert
        Assert.IsTrue(result.IsResolved);
        Assert.AreEqual("tenant123", result.TenantId);
    }

    [TestMethod]
    public async Task ResolveAsync_WithMultipleStrategies_UsesFirstSuccessful() {
        // Arrange
        var strategy1 = new TestTenantResolutionStrategy(null, priority: 10);
        var strategy2 = new TestTenantResolutionStrategy("tenant456", priority: 20);
        var parser = new DefaultTenantIdParser();
        var resolver = new TenantResolver<TestContext>(new ITenantResolutionStrategy<TestContext>[] { strategy1, strategy2 }, parser);

        // Act
        var result = await resolver.ResolveAsync(new TestContext());

        // Assert
        Assert.IsTrue(result.IsResolved);
        Assert.AreEqual("tenant456", result.TenantId);
    }

    [TestMethod]
    public async Task ResolveAsync_WithNoSuccessfulStrategy_ReturnsUnresolved() {
        // Arrange
        var strategy = new TestTenantResolutionStrategy(null, priority: 10);
        var parser = new DefaultTenantIdParser();
        var resolver = new TenantResolver<TestContext>(new[] { strategy }, parser);

        // Act
        var result = await resolver.ResolveAsync(new TestContext());

        // Assert
        Assert.IsFalse(result.IsResolved);
    }

    [TestMethod]
    public async Task ResolveAsync_RespectsStrategyPriority() {
        // Arrange
        var strategy1 = new TestTenantResolutionStrategy("tenant1", priority: 20);
        var strategy2 = new TestTenantResolutionStrategy("tenant2", priority: 10);
        var parser = new DefaultTenantIdParser();
        var resolver = new TenantResolver<TestContext>(new ITenantResolutionStrategy<TestContext>[] { strategy1, strategy2 }, parser);

        // Act
        var result = await resolver.ResolveAsync(new TestContext());

        // Assert
        Assert.IsTrue(result.IsResolved);
        Assert.AreEqual("tenant2", result.TenantId); // Lower priority wins
    }

    private class TestContext {
    }

    private class TestTenantResolutionStrategy : ITenantResolutionStrategy<TestContext> {
        private readonly string? _tenantId;

        public TestTenantResolutionStrategy(string? tenantId, int priority) {
            _tenantId = tenantId;
            Priority = priority;
        }

        public int Priority {
            get;
        }

        public Task<string?> ResolveAsync(TestContext context) {
            return Task.FromResult(_tenantId);
        }
    }
}
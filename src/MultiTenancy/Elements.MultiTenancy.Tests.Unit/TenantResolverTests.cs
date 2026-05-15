using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy;

namespace Elements.MultiTenancy.Abstractions.Tests.Unit;

[TestClass]
public class TenantResolverTests
{
    [TestMethod]
    public async Task ResolveAsync_WithValidStrategy_ReturnsTenantContext()
    {
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
    public async Task ResolveAsync_WithMultipleStrategies_UsesFirstSuccessful()
    {
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
    public async Task ResolveAsync_WithNoSuccessfulStrategy_ReturnsUnresolved()
    {
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
    public async Task ResolveAsync_RespectsStrategyPriority()
    {
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

    [TestMethod]
    public void Constructor_When_TenantIdParser_Is_Null_Then_Throws()
    {
        // Arrange
        var strategy = new TestTenantResolutionStrategy("tenant123", priority: 10);

        // Act & Assert
        Assert.ThrowsExactly<ArgumentNullException>(() => new TenantResolver<TestContext>(new[] { strategy }, null!));
    }

    [TestMethod]
    public async Task ResolveAsync_When_Strategy_Returns_Whitespace_Then_Returns_Unresolved()
    {
        // Arrange
        var strategy = new TestTenantResolutionStrategy("   ", priority: 10);
        var resolver = new TenantResolver<TestContext>(new[] { strategy }, new DefaultTenantIdParser());

        // Act
        var result = await resolver.ResolveAsync(new TestContext());

        // Assert
        Assert.IsFalse(result.IsResolved);
    }

    [TestMethod]
    public async Task ResolveAsync_When_Parser_Returns_Whitespace_Then_Returns_Unresolved()
    {
        // Arrange
        var strategy = new TestTenantResolutionStrategy("tenant123", priority: 10);
        var resolver = new TenantResolver<TestContext>(new[] { strategy }, new WhitespaceTenantIdParser());

        // Act
        var result = await resolver.ResolveAsync(new TestContext());

        // Assert
        Assert.IsFalse(result.IsResolved);
    }

    private class TestContext
    {
    }

    private class TestTenantResolutionStrategy : ITenantResolutionStrategy<TestContext>
    {
        private readonly string? _tenantId;

        public TestTenantResolutionStrategy(string? tenantId, int priority)
        {
            _tenantId = tenantId;
            Priority = priority;
        }

        public int Priority
        {
            get;
        }

        public Task<string?> ResolveAsync(TestContext context)
        {
            return Task.FromResult(_tenantId);
        }
    }

    private class WhitespaceTenantIdParser : ITenantIdParser
    {
        public string? Parse(string? rawTenantId)
        {
            return "   ";
        }
    }
}
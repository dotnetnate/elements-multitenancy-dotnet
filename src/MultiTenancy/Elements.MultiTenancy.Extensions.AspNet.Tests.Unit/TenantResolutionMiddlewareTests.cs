using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy;
using MyOrg.Elements.MultiTenancy.AspNet;

namespace Elements.MultiTenancy.Extensions.AspNet.Tests.Unit;

[TestClass]
public class TenantResolutionMiddlewareTests
{
    [TestMethod]
    public async Task InvokeAsync_SetsTenantContext_AndClearsAfterRequest()
    {
        // Arrange
        var accessor = new TenantContextAccessor();
        var resolver = new StubTenantResolver("tenant1");
        ITenantContext? capturedContext = null;

        RequestDelegate next = ctx =>
        {
            capturedContext = accessor.TenantContext;
            return Task.CompletedTask;
        };

        var middleware = new TenantResolutionMiddleware(next, resolver, accessor);
        var httpContext = new DefaultHttpContext();

        // Act
        await middleware.InvokeAsync(httpContext);

        // Assert - during the request, tenant was set
        Assert.IsNotNull(capturedContext);
        Assert.IsTrue(capturedContext.IsResolved);
        Assert.AreEqual("tenant1", capturedContext.TenantId);

        // Assert - after the request, tenant context is cleared
        Assert.IsNull(accessor.TenantContext);
    }

    [TestMethod]
    public async Task InvokeAsync_ClearsTenantContext_EvenOnException()
    {
        // Arrange
        var accessor = new TenantContextAccessor();
        var resolver = new StubTenantResolver("tenant1");

        RequestDelegate next = _ => throw new InvalidOperationException("test exception");

        var middleware = new TenantResolutionMiddleware(next, resolver, accessor);
        var httpContext = new DefaultHttpContext();

        // Act & Assert
        await Assert.ThrowsExactlyAsync<InvalidOperationException>(
            () => middleware.InvokeAsync(httpContext));

        // Tenant context should still be cleared
        Assert.IsNull(accessor.TenantContext);
    }

    [TestMethod]
    public async Task InvokeAsync_WithUnresolvedTenant_SetsUnresolvedContext()
    {
        // Arrange
        var accessor = new TenantContextAccessor();
        var resolver = new StubTenantResolver(null);
        ITenantContext? capturedContext = null;

        RequestDelegate next = ctx =>
        {
            capturedContext = accessor.TenantContext;
            return Task.CompletedTask;
        };

        var middleware = new TenantResolutionMiddleware(next, resolver, accessor);
        var httpContext = new DefaultHttpContext();

        // Act
        await middleware.InvokeAsync(httpContext);

        // Assert
        Assert.IsNotNull(capturedContext);
        Assert.IsFalse(capturedContext.IsResolved);
    }

    [TestMethod]
    public async Task InvokeAsync_When_Logger_Is_Provided_Then_Resolves_And_Clears_Context()
    {
        // Arrange
        var accessor = new TenantContextAccessor();
        var resolver = new StubTenantResolver("tenant1");
        var middleware = new TenantResolutionMiddleware(
            _ => Task.CompletedTask,
            resolver,
            accessor,
            NullLogger<TenantResolutionMiddleware>.Instance);

        // Act
        await middleware.InvokeAsync(new DefaultHttpContext());

        // Assert
        Assert.IsNull(accessor.TenantContext);
    }

    [TestMethod]
    public void Constructor_When_Next_Is_Null_Then_Throws()
    {
        // Arrange
        var accessor = new TenantContextAccessor();
        var resolver = new StubTenantResolver("tenant1");

        // Act & Assert
        Assert.ThrowsExactly<ArgumentNullException>(() => new TenantResolutionMiddleware(null!, resolver, accessor));
    }

    [TestMethod]
    public void Constructor_When_Resolver_Is_Null_Then_Throws()
    {
        // Arrange
        var accessor = new TenantContextAccessor();
        RequestDelegate next = _ => Task.CompletedTask;

        // Act & Assert
        Assert.ThrowsExactly<ArgumentNullException>(() => new TenantResolutionMiddleware(next, null!, accessor));
    }

    [TestMethod]
    public void Constructor_When_Accessor_Is_Null_Then_Throws()
    {
        // Arrange
        var resolver = new StubTenantResolver("tenant1");
        RequestDelegate next = _ => Task.CompletedTask;

        // Act & Assert
        Assert.ThrowsExactly<ArgumentNullException>(() => new TenantResolutionMiddleware(next, resolver, null!));
    }

    private class StubTenantResolver : ITenantResolver<HttpContext>
    {
        private readonly string? _tenantId;

        public StubTenantResolver(string? tenantId) => _tenantId = tenantId;

        public Task<ITenantContext> ResolveAsync(HttpContext context)
        {
            ITenantContext result = _tenantId != null
                ? new TenantContext(_tenantId)
                : TenantContext.Unresolved;
            return Task.FromResult(result);
        }
    }
}
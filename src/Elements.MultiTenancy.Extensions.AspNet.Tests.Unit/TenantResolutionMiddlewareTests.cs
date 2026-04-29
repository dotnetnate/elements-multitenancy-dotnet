using Microsoft.AspNetCore.Http;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MyOrg.Elements.MultiTenancy;
using MyOrg.Elements.MultiTenancy.AspNet;

namespace Elements.MultiTenancy.Extensions.AspNet.Tests.Unit;

[TestClass]
public class TenantResolutionMiddlewareTests {
    [TestMethod]
    public async Task InvokeAsync_SetsTenantContext_AndClearsAfterRequest() {
        // Arrange
        var accessor = new TenantContextAccessor();
        var resolver = new StubTenantResolver("tenant1");
        ITenantContext? capturedContext = null;

        RequestDelegate next = ctx => {
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
    public async Task InvokeAsync_ClearsTenantContext_EvenOnException() {
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
    public async Task InvokeAsync_WithUnresolvedTenant_SetsUnresolvedContext() {
        // Arrange
        var accessor = new TenantContextAccessor();
        var resolver = new StubTenantResolver(null);
        ITenantContext? capturedContext = null;

        RequestDelegate next = ctx => {
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

    private class StubTenantResolver : ITenantResolver<HttpContext> {
        private readonly string? _tenantId;

        public StubTenantResolver(string? tenantId) => _tenantId = tenantId;

        public Task<ITenantContext> ResolveAsync(HttpContext context) {
            ITenantContext result = _tenantId != null
                ? new TenantContext(_tenantId)
                : TenantContext.Unresolved;
            return Task.FromResult(result);
        }
    }
}
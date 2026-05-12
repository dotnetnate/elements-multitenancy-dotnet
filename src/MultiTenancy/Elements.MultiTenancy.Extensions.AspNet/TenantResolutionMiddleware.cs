using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using MyOrg.Elements.MultiTenancy;

namespace MyOrg.Elements.MultiTenancy.AspNet;

/// <summary>
/// Middleware for resolving and setting the tenant context.
/// </summary>
/// <example>
/// <code language="csharp">
/// // Registered via UseElementsMultiTenancy(); resolves tenant per request and
/// // populates ITenantContextAccessor for the duration of the pipeline.
/// var app = builder.Build();
/// app.UseElementsMultiTenancy();
/// app.MapGet("/whoami", (ITenantContextAccessor tca) =>
///     tca.TenantContext is { IsResolved: true } ctx ? ctx.TenantId : "unresolved");
/// </code>
/// </example>
public sealed class TenantResolutionMiddleware {
    private readonly RequestDelegate _next;
    private readonly ITenantResolver<HttpContext> _tenantResolver;
    private readonly ITenantContextAccessor _tenantContextAccessor;
    private readonly ILogger<TenantResolutionMiddleware>? _logger;

    /// <summary>
    /// Initializes a new instance of the <see cref="TenantResolutionMiddleware"/> class.
    /// </summary>
    /// <param name="next">The next middleware in the pipeline.</param>
    /// <param name="tenantResolver">The tenant resolver.</param>
    /// <param name="tenantContextAccessor">The tenant context accessor.</param>
    /// <param name="logger">The logger.</param>
    /// <exception cref="ArgumentNullException">
    /// Thrown when <paramref name="next"/>, <paramref name="tenantResolver"/>, or
    /// <paramref name="tenantContextAccessor"/> is <c>null</c>.
    /// </exception>
    /// <example>
    /// <code language="csharp">
    /// // Instantiated by the ASP.NET Core middleware pipeline; not constructed directly.
    /// app.UseMiddleware&lt;TenantResolutionMiddleware&gt;();
    /// </code>
    /// </example>
    public TenantResolutionMiddleware(
        RequestDelegate next,
        ITenantResolver<HttpContext> tenantResolver,
        ITenantContextAccessor tenantContextAccessor,
        ILogger<TenantResolutionMiddleware>? logger = null) {
        _next = next ?? throw new ArgumentNullException(nameof(next));
        _tenantResolver = tenantResolver ?? throw new ArgumentNullException(nameof(tenantResolver));
        _tenantContextAccessor = tenantContextAccessor ?? throw new ArgumentNullException(nameof(tenantContextAccessor));
        _logger = logger;
    }

    /// <summary>
    /// Invokes the middleware.
    /// </summary>
    /// <param name="context">The HTTP context.</param>
    /// <returns>A task that completes when the downstream pipeline has finished executing.</returns>
    /// <example>
    /// <code language="csharp">
    /// // Called automatically by the ASP.NET Core pipeline; equivalent to:
    /// await middleware.InvokeAsync(httpContext);
    /// </code>
    /// </example>
    public async Task InvokeAsync(HttpContext context) {
        var tenantContext = await _tenantResolver.ResolveAsync(context);
        _tenantContextAccessor.TenantContext = tenantContext;
        _logger?.LogDebug("Resolved tenant: {TenantId}, IsResolved: {IsResolved}", tenantContext.TenantId, tenantContext.IsResolved);

        try {
            await _next(context);
        }
        finally {
            // Clear the tenant context after the request completes
            _tenantContextAccessor.TenantContext = null;
        }
    }
}
using Microsoft.AspNetCore.Http;
using MyOrg.Elements.MultiTenancy;

namespace MyOrg.Elements.MultiTenancy.AspNet;

/// <summary>
/// Resolves tenant ID from HTTP headers.
/// </summary>
/// <example>
/// <code language="csharp">
/// // Registered automatically by AddElementsMultiTenancy when ResolveFromHeader = true.
/// services.AddElementsMultiTenancy(options =>
/// {
///     options.ResolveFromHeader = true;
///     options.HeaderName = "X-Tenant-Id";
/// });
/// // Clients then send: GET /api/orders   X-Tenant-Id: contoso
/// </code>
/// </example>
public sealed class HeaderTenantResolutionStrategy : ITenantResolutionStrategy<HttpContext> {
    private readonly MultiTenancyOptions _options;

    /// <summary>
    /// Initializes a new instance of the <see cref="HeaderTenantResolutionStrategy"/> class.
    /// </summary>
    /// <param name="options">The multi-tenancy options.</param>
    /// <exception cref="ArgumentNullException">
    /// Thrown when <paramref name="options"/> is <c>null</c>.
    /// </exception>
    /// <example>
    /// <code language="csharp">
    /// var strategy = new HeaderTenantResolutionStrategy(options);
    /// </code>
    /// </example>
    public HeaderTenantResolutionStrategy(MultiTenancyOptions options) {
        _options = options ?? throw new ArgumentNullException(nameof(options));
    }

    /// <inheritdoc/>
    public int Priority => 20;

    /// <inheritdoc/>
    public Task<string?> ResolveAsync(HttpContext context) {
        if (context.Request.Headers.TryGetValue(_options.HeaderName, out var headerValue)) {
            return Task.FromResult<string?>(headerValue.ToString());
        }

        return Task.FromResult<string?>(null);
    }
}
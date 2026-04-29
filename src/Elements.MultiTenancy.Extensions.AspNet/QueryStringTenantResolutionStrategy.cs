using Microsoft.AspNetCore.Http;
using MyOrg.Elements.MultiTenancy;

namespace MyOrg.Elements.MultiTenancy.AspNet;

/// <summary>
/// Resolves tenant ID from query string parameters.
/// </summary>
/// <example>
/// <code language="csharp">
/// // Registered automatically by AddElementsMultiTenancy when ResolveFromQueryString = true.
/// services.AddElementsMultiTenancy(options =>
/// {
///     options.ResolveFromQueryString = true;
///     options.QueryStringParameterName = "tenant";
/// });
/// // A request to /api/orders?tenant=contoso will resolve tenant "contoso".
/// </code>
/// </example>
public sealed class QueryStringTenantResolutionStrategy : ITenantResolutionStrategy<HttpContext> {
    private readonly MultiTenancyOptions _options;

    /// <summary>
    /// Initializes a new instance of the <see cref="QueryStringTenantResolutionStrategy"/> class.
    /// </summary>
    /// <param name="options">The multi-tenancy options.</param>
    /// <exception cref="ArgumentNullException">
    /// Thrown when <paramref name="options"/> is <c>null</c>.
    /// </exception>
    /// <example>
    /// <code language="csharp">
    /// var strategy = new QueryStringTenantResolutionStrategy(options);
    /// </code>
    /// </example>
    public QueryStringTenantResolutionStrategy(MultiTenancyOptions options) {
        _options = options ?? throw new ArgumentNullException(nameof(options));
    }

    /// <inheritdoc/>
    public int Priority => 40;

    /// <inheritdoc/>
    public Task<string?> ResolveAsync(HttpContext context) {
        if (context.Request.Query.TryGetValue(_options.QueryStringParameterName, out var queryValue)) {
            return Task.FromResult<string?>(queryValue.ToString());
        }

        return Task.FromResult<string?>(null);
    }
}
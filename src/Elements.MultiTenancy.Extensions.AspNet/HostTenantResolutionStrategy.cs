using Microsoft.AspNetCore.Http;
using MyOrg.Elements.MultiTenancy;

namespace MyOrg.Elements.MultiTenancy.AspNet;

/// <summary>
/// Resolves tenant ID from the host name or subdomain.
/// </summary>
/// <example>
/// <code language="csharp">
/// // Registered automatically by AddElementsMultiTenancy when ResolveFromHost = true.
/// services.AddElementsMultiTenancy(options =>
/// {
///     options.ResolveFromHost = true;
///     // Optionally override the default subdomain parser.
///     options.HostParser = host => host.Split('.')[0];
/// });
/// // A request to https://contoso.example.com/api will resolve tenant "contoso".
/// </code>
/// </example>
public sealed class HostTenantResolutionStrategy : ITenantResolutionStrategy<HttpContext> {
    private readonly MultiTenancyOptions _options;

    /// <summary>
    /// Initializes a new instance of the <see cref="HostTenantResolutionStrategy"/> class.
    /// </summary>
    /// <param name="options">The multi-tenancy options.</param>
    /// <exception cref="ArgumentNullException">
    /// Thrown when <paramref name="options"/> is <c>null</c>.
    /// </exception>
    /// <example>
    /// <code language="csharp">
    /// var strategy = new HostTenantResolutionStrategy(options);
    /// </code>
    /// </example>
    public HostTenantResolutionStrategy(MultiTenancyOptions options) {
        _options = options ?? throw new ArgumentNullException(nameof(options));
    }

    /// <inheritdoc/>
    public int Priority => 30;

    /// <inheritdoc/>
    public Task<string?> ResolveAsync(HttpContext context) {
        var host = context.Request.Host.Host;
        var tenantId = _options.HostParser(host);

        return Task.FromResult(tenantId);
    }
}
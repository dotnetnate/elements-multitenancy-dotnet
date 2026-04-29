using Microsoft.AspNetCore.Http;
using MyOrg.Elements.MultiTenancy;
using MyOrg.Elements.Security.Identity;
using System.Security.Claims;

namespace MyOrg.Elements.MultiTenancy.AspNet;

/// <summary>
/// Resolves tenant ID from ClaimsPrincipal claims.
/// </summary>
/// <example>
/// <code language="csharp">
/// // Registered automatically by AddElementsMultiTenancy when ResolveFromClaims = true.
/// services.AddElementsMultiTenancy(options =>
/// {
///     options.ResolveFromClaims = true;
///     options.ClaimType = "tenant_id";
/// });
/// // The strategy then runs as part of TenantResolutionMiddleware on every request.
/// </code>
/// </example>
public sealed class ClaimsTenantResolutionStrategy : ITenantResolutionStrategy<HttpContext> {
    private readonly MultiTenancyOptions _options;
    private readonly WellKnownClaimsConfiguration _claimsConfig;

    /// <summary>
    /// Initializes a new instance of the <see cref="ClaimsTenantResolutionStrategy"/> class.
    /// </summary>
    /// <param name="options">The multi-tenancy options.</param>
    /// <param name="claimsConfig">The well-known claims configuration.</param>
    /// <exception cref="ArgumentNullException">
    /// Thrown when <paramref name="options"/> or <paramref name="claimsConfig"/> is <c>null</c>.
    /// </exception>
    /// <example>
    /// <code language="csharp">
    /// var strategy = new ClaimsTenantResolutionStrategy(options, claimsConfig);
    /// </code>
    /// </example>
    public ClaimsTenantResolutionStrategy(
        MultiTenancyOptions options,
        WellKnownClaimsConfiguration claimsConfig) {
        _options = options ?? throw new ArgumentNullException(nameof(options));
        _claimsConfig = claimsConfig ?? throw new ArgumentNullException(nameof(claimsConfig));
    }

    /// <inheritdoc/>
    public int Priority => 10;

    /// <inheritdoc/>
    public Task<string?> ResolveAsync(HttpContext context) {
        var user = context.User;
        if (user?.Identity?.IsAuthenticated != true) {
            return Task.FromResult<string?>(null);
        }

        var claimType = _options.ClaimType ?? _claimsConfig.TenantId;

        if (user.Identity is ClaimsIdentity identity) {
            if (identity.TryGetClaimValue(claimType, out var tenantId)) {
                return Task.FromResult<string?>(tenantId);
            }
        }

        return Task.FromResult<string?>(null);
    }
}